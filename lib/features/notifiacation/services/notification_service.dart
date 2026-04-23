import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartnursery/features/notifiacation/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crée une notification pour tous les utilisateurs d'une crèche
  /// (sauf l'auteur du post)
  Future<void> createNotificationForPost({
    required String postId,
    required String authorId,
    required String authorName,
    required String? authorProfileImage,
    required String postContent,
    required String nurseryId,
  }) async {
    try {
      debugPrint(
        '🔔 Création des notifications pour le post $postId de nursery $nurseryId',
      );

      if (nurseryId.isEmpty) {
        debugPrint('⚠️ nurseryId vide - notifications non créées');
        return;
      }

      // Récupérer tous les utilisateurs de la crèche
      final usersSnapshot = await _firestore
          .collection('users')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      debugPrint(
        '👥 Trouvé ${usersSnapshot.docs.length} utilisateurs dans la crèche',
      );

      int notificationCount = 0;

      // Créer une notification pour chaque utilisateur (sauf l'auteur)
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userRole = userDoc.data()['role'] ?? '';

        if (userId == authorId) {
          debugPrint('⏭️ Skipping auteur $authorId');
          continue; // Ne pas notifier l'auteur
        }

        try {
          // Utiliser add() pour générer un ID unique automatiquement
          final newNotificationRef = _firestore
              .collection('notifications')
              .doc();

          final notification = NotificationModel(
            notificationId: newNotificationRef.id,
            userId: userId,
            type: 'post',
            title: 'Nouvelle publication',
            message: postContent.length > 50
                ? postContent.substring(0, 50) + '...'
                : postContent,
            sourceUserId: authorId,
            sourceUserName: authorName,
            sourceUserProfileImage: authorProfileImage,
            postId: postId,
            isRead: false,
            createdAt: DateTime.now(),
            nurseryId: nurseryId,
          );

          await newNotificationRef.set(notification.toMap());
          notificationCount++;
          debugPrint(
            '✅ Notification créée pour user $userId (role: $userRole)',
          );
        } catch (e) {
          debugPrint('❌ Erreur création notification pour $userId: $e');
        }
      }

      debugPrint(
        '✅ $notificationCount notifications créées pour le post $postId',
      );
    } catch (e) {
      debugPrint('❌ Erreur critique lors de la création des notifications: $e');
      rethrow;
    }
  }

  /// Récupère les notifications du l'utilisateur courant
  Stream<List<NotificationModel>> getNotificationsStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value([]);

      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
                .toList();
          })
          .handleError((error) {
            debugPrint('❌ Erreur dans le stream des notifications: $error');
            return [];
          });
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return Stream.value([]);
    }
  }

  /// Récupère les notifications non lues
  Stream<List<NotificationModel>> getUnreadNotificationsStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value([]);

      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
                .toList();
          })
          .handleError((error) {
            debugPrint(
              '❌ Erreur dans le stream des notifications non lues: $error',
            );
            return [];
          });
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return Stream.value([]);
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      debugPrint('✅ Notification marquée comme lue');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }

      debugPrint('✅ Toutes les notifications marquées comme lues');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      debugPrint('✅ Notification supprimée');
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return 0;
    }
  }

  /// Stream du nombre de notifications non lues
  Stream<int> getUnreadCountStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value(0);

      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
            debugPrint('❌ Erreur: $error');
            return 0;
          });
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      return Stream.value(0);
    }
  }

  /// Diagnostic: Affiche toutes les notifications créées pour déboguer
  Future<void> debugPrintAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ Aucun utilisateur connecté');
        return;
      }

      debugPrint('🔍 Diagnostic - UserId: ${user.uid}');

      // Vérifier les notifications pour cet utilisateur
      final userNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .get();

      debugPrint(
        '📊 ${userNotifications.docs.length} notifications pour cet utilisateur',
      );

      for (final doc in userNotifications.docs) {
        final data = doc.data();
        debugPrint('  - Notification ${doc.id}:');
        debugPrint('    Type: ${data['type']}');
        debugPrint('    Title: ${data['title']}');
        debugPrint('    SourceUser: ${data['sourceUserName']}');
        debugPrint('    CreatedAt: ${data['createdAt']}');
      }

      // Vérifier TOUTES les notifications dans Firestore
      final allNotifications = await _firestore
          .collection('notifications')
          .limit(50)
          .get();

      debugPrint(
        '📊 Total notifications dans Firestore: ${allNotifications.docs.length}',
      );
    } catch (e) {
      debugPrint('❌ Erreur diagnostic: $e');
    }
  }
}
