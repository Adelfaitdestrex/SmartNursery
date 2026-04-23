import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnursery/services/firebase/firebase_options.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retourne null si succès, sinon le message d'erreur
  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Email ou mot de passe incorrect.';
        case 'invalid-email':
          return 'Email invalide.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard.';
        default:
          return e.message ?? 'Une erreur est survenue.';
      }
    }
  }

  Future<String?> createAccount(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'email-already-in-use':
          return 'Un compte existe déjà pour cet email.';
        case 'invalid-email':
          return 'Email invalide.';
        default:
          return e.message ?? 'Une erreur est survenue.';
      }
    }
  }

  Future<String?> createAccountOnSecondaryApp(
    String email,
    String password,
  ) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'admin-create-${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'email-already-in-use':
          return 'Un compte existe déjà pour cet email.';
        case 'invalid-email':
          return 'Email invalide.';
        default:
          return e.message ?? 'Une erreur est survenue.';
      }
    } catch (e) {
      return e.toString();
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  Future<void> saveUserData({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? childrenIds,
    List<String>? classIds,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userId': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'nurseryId': '1', // ✅ Automatiquement assigné à la crèche 1
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber,
      if (profileImageUrl != null && profileImageUrl.isNotEmpty)
        'profileImageUrl': profileImageUrl,
      if (childrenIds != null && childrenIds.isNotEmpty)
        'childrenIds': childrenIds,
      if (classIds != null && classIds.isNotEmpty) 'classIds': classIds,
      'settings': {},
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
