import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import 'package:smartnursery/features/notifiacation/services/notification_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() ?? {};
          debugPrint('✅ Document utilisateur trouvé: $data');

          // Si firstName/lastName manquent, utiliser l'email comme fallback
          if ((data['firstName'] ?? '').isEmpty &&
              (data['lastName'] ?? '').isEmpty) {
            final nameParts = user.email?.split('@').first.split('.') ?? [];
            return {
              ...data,
              'firstName': nameParts.isNotEmpty ? nameParts[0] : 'User',
              'lastName': nameParts.length > 1 ? nameParts[1] : '',
            };
          }

          return data;
        } else {
          debugPrint(
            '⚠️ Document utilisateur n\'existe pas. Création du document de base...',
          );
          // Créer un document utilisateur minimal si inexistant
          final userData = {
            'userId': user.uid,
            'email': user.email ?? '',
            'firstName': user.displayName ?? 'User',
            'lastName': '',
            'createdAt': FieldValue.serverTimestamp(),
          };
          await _firestore.collection('users').doc(user.uid).set(userData);
          return userData;
        }
      } catch (e) {
        debugPrint('❌ Erreur: $e');
      }
    } else {
      debugPrint('⚠️ Aucun utilisateur connecté');
    }
    return null;
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('publications/$fileName.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> createPost({
    required String content,
    List<String> mediaUrls = const [],
    List<String> classIds = const [],
    List<String> taggedUserIds = const [],
    List<String> taggedUserNames = const [],
    String visibility = 'all',
    String type = 'announcement',
    String? musicUrl,
    String? musicTitle,
    String? musicArtist,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Vous devez être connecté pour publier.');

    final userData = await getCurrentUserData();
    final role = (userData?['role'] ?? 'parent').toString();

    if (role == 'parent') {
      throw Exception('Les parents ne peuvent pas publier.');
    }

    // Récupérer le nom avec fallback
    String firstName = userData?['firstName'] ?? '';
    String lastName = userData?['lastName'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final nameParts = user.email?.split('@').first.split('.') ?? [];
      firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
      lastName = nameParts.length > 1 ? nameParts[1] : '';
    }

    final nurseryId = userData?['nurseryId'] ?? '';

    final postRef = _firestore.collection('posts').doc();

    final post = Post(
      postId: postRef.id,
      authorId: user.uid,
      authorName: '$firstName $lastName'.trim(),
      authorRole: role,
      authorProfileImageUrl: userData?['profileImageUrl'] ?? '',
      content: content,
      mediaUrls: mediaUrls,
      classIds: classIds,
      taggedUserIds: taggedUserIds,
      taggedUserNames: taggedUserNames,
      type: type,
      visibility: visibility,
      createdAt: DateTime.now(),
      musicUrl: musicUrl,
      musicTitle: musicTitle,
      musicArtist: musicArtist,
      nurseryId: nurseryId,
    );

    await postRef.set(post.toMap());
    debugPrint('✅ Post créé: ${postRef.id}');
    debugPrint(
      '📋 NurseryId: $nurseryId, AuthorId: ${user.uid}, AuthorName: $firstName $lastName',
    );

    // Créer une notification pour tous les utilisateurs de la crèche
    // (non-blocking - exécuté en arrière-plan)
    if (nurseryId.isNotEmpty) {
      debugPrint('🔔 Notification trigger pour nurseryId: $nurseryId');
      final notificationService = NotificationService();
      // Ne pas attendre pour ne pas bloquer la création du post
      unawaited(
        notificationService.createNotificationForPost(
          postId: postRef.id,
          authorId: user.uid,
          authorName: '$firstName $lastName'.trim(),
          authorProfileImage: userData?['profileImageUrl'],
          postContent: content,
          nurseryId: nurseryId,
        ),
      );
    } else {
      debugPrint('⚠️ NurseryId vide - pas de notification créée');
    }

    debugPrint('✅ Post créé avec notifications en arrière-plan');
  }

  /// Supprime un post (seulement l'auteur peut le faire)
  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Vous devez être connecté.');

    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();

      if (!postDoc.exists) {
        throw Exception('Post introuvable.');
      }

      final isAuthor = postDoc['authorId'] == user.uid;

      // Vérifier si l'utilisateur est admin ou director
      final userRole = await _getUserRole(user.uid);
      final isAdminOrDirector = userRole == 'admin' || userRole == 'director';

      if (!isAuthor && !isAdminOrDirector) {
        throw Exception(
          'Vous ne pouvez supprimer que vos propres posts. Seul un admin peut supprimer les posts d\'autres utilisateurs.',
        );
      }

      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Récupère le rôle de l'utilisateur
  Future<String> _getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['role'] ?? '';
    } catch (e) {
      debugPrint('❌ Erreur récupération rôle: $e');
      return '';
    }
  }

  /// Récupère tous les posts triés par date décroissante (les plus récents d'abord), filtrés par nurseryId
  Future<List<Post>> getPosts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final userData = await getCurrentUserData();
      final nurseryId = userData?['nurseryId'] as String? ?? '';

      if (nurseryId.isEmpty) {
        debugPrint('⚠️ Impossible de récupérer les posts - nurseryId vide');
        return [];
      }

      // Requête compatible règles Firestore (filtre nurseryId côté serveur),
      // puis tri local pour éviter l'index composite where + orderBy.
      final snapshot = await _firestore
          .collection('posts')
          .where('nurseryId', isEqualTo: nurseryId)
          .limit(100)
          .get();

      final posts = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching posts: $e');
      return [];
    }
  }

  /// Récupère un stream en temps réel de tous les posts de la nursery de l'utilisateur
  Stream<List<Post>> getPostsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncExpand((userDoc) {
          if (!userDoc.exists) {
            debugPrint('⚠️ Document utilisateur introuvable: ${user.uid}');
            return Stream.value(<Post>[]);
          }

          final data = userDoc.data();
          final nurseryId = data?['nurseryId'] as String? ?? '';
          if (nurseryId.isEmpty) {
            debugPrint('⚠️ nurseryId vide pour cet utilisateur');
            return Stream.value(<Post>[]);
          }

          return _firestore
              .collection('posts')
              .where('nurseryId', isEqualTo: nurseryId)
              .limit(50)
              .snapshots()
              .map((snapshot) {
                final posts = snapshot.docs
                    .map((doc) => Post.fromMap(doc.data(), doc.id))
                    .toList();
                posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return posts;
              });
        })
        .handleError((error) {
          debugPrint('❌ Error in posts stream: $error');
          return <Post>[];
        });
  }

  // ========== LIKES & REACTIONS ==========

  /// Toggle un like sur un post
  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Vous devez être connecté pour aimer.');

    final likesRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid);

    final likesSnapshot = await likesRef.get();

    if (likesSnapshot.exists) {
      // Si l'utilisateur a déjà liké, on supprime le like
      await likesRef.delete();
    } else {
      // Sinon on ajoute le like
      await likesRef.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Récupère le nombre de likes d'un post
  Future<int> getLikesCount(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting likes count: $e');
      return 0;
    }
  }

  /// Stream du nombre de likes
  Stream<int> getLikesCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Error in likes stream: $error');
          return 0;
        });
  }

  /// Récupère les likes avec les infos des utilisateurs
  Future<List<Map<String, dynamic>>> getLikesWithUserInfo(String postId) async {
    try {
      final likesSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .limit(3) // Limiter à 3 pour l'affichage
          .get();

      List<Map<String, dynamic>> likesWithInfo = [];

      for (final likeDoc in likesSnapshot.docs) {
        final userId = likeDoc.id;
        final userData = await _firestore.collection('users').doc(userId).get();

        if (userData.exists) {
          final data = userData.data() ?? {};
          String firstName = data['firstName'] ?? '';
          String lastName = data['lastName'] ?? '';

          // Fallback si noms manquants
          if (firstName.isEmpty && lastName.isEmpty) {
            final email = data['email'] ?? '';
            final nameParts = email.split('@').first.split('.');
            firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
            lastName = nameParts.length > 1 ? nameParts[1] : '';
          }

          likesWithInfo.add({
            'userId': userId,
            'name': '$firstName $lastName'.trim(),
            'profileImageUrl': data['profileImageUrl'] ?? '',
          });
        }
      }

      return likesWithInfo;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des likes: $e');
      return [];
    }
  }

  /// Vérifie si l'utilisateur a liké ce post
  Future<bool> hasUserLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  // ========== COMMENTS ==========

  /// Ajoute un commentaire à un post
  Future<void> addComment(String postId, String commentText) async {
    final user = _auth.currentUser;
    if (user == null)
      throw Exception('Vous devez être connecté pour commenter.');

    if (commentText.trim().isEmpty) {
      throw Exception('Le commentaire ne peut pas être vide.');
    }

    final userData = await getCurrentUserData();

    // Récupérer le nom avec fallback
    String firstName = userData?['firstName'] ?? '';
    String lastName = userData?['lastName'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final nameParts = user.email?.split('@').first.split('.') ?? [];
      firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
      lastName = nameParts.length > 1 ? nameParts[1] : '';
    }

    final profileImageUrl = userData?['profileImageUrl'] ?? '';

    final commentsRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await commentsRef.set({
      'commentId': commentsRef.id,
      'authorId': user.uid,
      'authorName': '$firstName $lastName'.trim(),
      'authorProfileImageUrl': profileImageUrl,
      'content': commentText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère les commentaires d'un post (stream temps réel)
  Stream<List<Map<String, dynamic>>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        })
        .handleError((error) {
          print('Error in comments stream: $error');
          return [];
        });
  }

  /// Récupère le nombre de commentaires
  Stream<int> getCommentsCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print('Error in comments count stream: $error');
          return 0;
        });
  }

  // ========== USERS ==========

  /// Récupère les utilisateurs du même établissement
  Future<List<Map<String, dynamic>>> getUsersForNursery() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Récupérer l'ID de la crèche de l'utilisateur actuel
      final userData = await getCurrentUserData();
      final nurseryId = userData?['nurseryId'];

      if (nurseryId == null) {
        print('⚠️  L\'utilisateur n\'a pas de nurseryId');
        return [];
      }

      // Récupérer tous les utilisateurs du même établissement
      final snapshot = await _firestore
          .collection('users')
          .where('nurseryId', isEqualTo: nurseryId)
          .where(
            'userId',
            isNotEqualTo: user.uid,
          ) // Exclure l'utilisateur actuel
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        String firstName = data['firstName'] ?? '';
        String lastName = data['lastName'] ?? '';

        // Fallback: générer à partir de l'email si les noms sont manquants
        if (firstName.isEmpty && lastName.isEmpty) {
          final email = data['email'] ?? '';
          final nameParts = email.split('@').first.split('.');
          firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
          lastName = nameParts.length > 1 ? nameParts[1] : '';
        }

        return {
          'userId': doc.id,
          'firstName': firstName,
          'lastName': lastName,
          'role': data['role'] ?? 'user',
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching users for nursery: $e');
      return [];
    }
  }
}
