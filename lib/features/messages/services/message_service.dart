import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtenir ou créer une conversation entre 2 utilisateurs
  Future<String> getOrCreateConversation(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('Utilisateur non connecté');

    // Créer un ID de conversation basé sur les 2 IDs (toujours dans le même ordre)
    final ids = [currentUserId, otherUserId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';

    try {
      final doc = await _firestore
          .collection('messages')
          .doc(conversationId)
          .get();

      // Si la conversation n'existe pas, la créer
      if (!doc.exists) {
        await _firestore.collection('messages').doc(conversationId).set({
          'conversationId': conversationId,
          'participantIds': [currentUserId, otherUserId],
          'lastMessage': null,
          'unreadCount': {currentUserId: 0, otherUserId: 0},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return conversationId;
    } catch (e) {
      debugPrint('❌ Erreur création conversation: $e');
      rethrow;
    }
  }

  /// Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required String recipientId,
    String type = 'text',
    String? mediaUrl,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('Utilisateur non connecté');

    try {
      final chatRef = _firestore
          .collection('messages')
          .doc(conversationId)
          .collection('chatMessages');
      final conversationRef = _firestore
          .collection('messages')
          .doc(conversationId);

      // 1️⃣ Ajouter le message dans la sous-collection chatMessages
      final docRef = await chatRef.add({
        'senderId': currentUserId,
        'recipientId': recipientId,
        'content': content,
        'type': type,
        'mediaUrl': mediaUrl,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2️⃣ Mettre à jour le messageId avec son propre ID Firestore
      await docRef.update({'messageId': docRef.id});

      // 3️⃣ Mettre à jour lastMessage + updatedAt sur la conversation
      await conversationRef.update({
        'lastMessage': {
          'senderId': currentUserId,
          'recipientId': recipientId,
          'content': content,
          'createdAt': FieldValue.serverTimestamp(),
        },
        'unreadCount.$recipientId': FieldValue.increment(1),
        'unreadCount.$currentUserId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Erreur envoi message: $e');
      rethrow;
    }
  }

  /// Marquer tous les messages non lus comme lus
  Future<void> markMessagesAsRead(String conversationId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final unreadDocs = await _firestore
          .collection('messages')
          .doc(conversationId)
          .collection('chatMessages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      await _firestore.collection('messages').doc(conversationId).update({
        'unreadCount.$currentUserId': 0,
      });
    } catch (e) {
      debugPrint('❌ Erreur markAsRead: $e');
    }
  }

  /// Obtenir les messages d'une conversation
  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _firestore
        .collection('messages')
        .doc(conversationId)
        .collection('chatMessages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Rechercher les utilisateurs
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final currentUserId = _auth.currentUser?.uid;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: query + 'z')
          .get();

      // Filtrer le user courant et convertir en Map
      return querySnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map(
            (doc) => {
              'id': doc.id,
              'firstName': doc['firstName'] ?? '',
              'lastName': doc['lastName'] ?? '',
              'profileImageUrl': doc['profileImageUrl'] ?? '',
              'role': doc['role'] ?? '',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur recherche utilisateurs: $e');
      return [];
    }
  }

  /// Obtenir les conversations récentes de l'utilisateur
  Stream<QuerySnapshot> getUserConversations() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('messages')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// Obtenir tous les utilisateurs (hors soi-même) en temps réel
  Stream<QuerySnapshot> getAllUsers() {
    final currentUserId = _auth.currentUser?.uid;
    // Firestore ne supporte pas != dans where sur le même champ avec orderBy,
    // on filtre donc côté client dans le widget.
    return _firestore.collection('users').orderBy('firstName').snapshots();
  }

  /// Obtenir les infos d'un utilisateur
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur récupération user: $e');
      return null;
    }
  }

  /// Compter les messages non lus dans une conversation
  Future<int> getUnreadMessageCount(String conversationId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return 0;

    try {
      final unreadDocs = await _firestore
          .collection('messages')
          .doc(conversationId)
          .collection('chatMessages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .count()
          .get();

      return unreadDocs.count ?? 0;
    } catch (e) {
      debugPrint('❌ Erreur comptage messages non lus: $e');
      return 0;
    }
  }
}
