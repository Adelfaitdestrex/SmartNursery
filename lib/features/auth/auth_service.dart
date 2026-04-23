import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _requestResetCodeEndpoint =
      'https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/requestPasswordResetCode';
  static const String _resetPasswordEndpoint =
      'https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/resetPasswordWithCode';

  /// Demande l'envoi d'un code de réinitialisation de mot de passe à l'email fourni
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return {
          'success': false,
          'message': 'Veuillez entrer une adresse email valide',
        };
      }

      final response = await http.post(
        Uri.parse(_requestResetCodeEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (kDebugMode) {
          debugPrint('Reset code sent to $email');
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Code de vérification envoyé à $email',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'envoi de l\'email.',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Password reset request error: $e');
      }
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez réessayer.',
      };
    }
  }

  /// Change le mot de passe pour un utilisateur via OTP et la Cloud Function
  static Future<Map<String, dynamic>> changePasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Le mot de passe doit contenir au moins 6 caractères',
        };
      }

      final response = await http.post(
        Uri.parse(_resetPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Mot de passe changé avec succès'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Code invalide ou expiré',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Password change with OTP error: $e');
      }
      return {
        'success': false,
        'message': 'Erreur lors du changement de mot de passe',
      };
    }
  }

  /// Change le mot de passe pour l'utilisateur actuellement connecté
  static Future<Map<String, dynamic>> changePasswordCurrentUser(
    String newPassword,
  ) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return {'success': false, 'message': 'Aucun utilisateur connecté'};
      }

      // Valider le mot de passe
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Le mot de passe doit contenir au moins 6 caractères',
        };
      }

      await currentUser.updatePassword(newPassword);

      return {'success': true, 'message': 'Mot de passe changé avec succès'};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Password change error: $e');
      }

      String errorMessage = 'Une erreur s\'est produite';

      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe est trop faible';
        } else if (e.code == 'requires-recent-login') {
          errorMessage =
              'Veuillez vous reconnecter pour changer votre mot de passe';
        } else {
          errorMessage =
              e.message ?? 'Erreur lors du changement de mot de passe';
        }
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  /// Vérifie si un email existe dans Firebase
  static Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email check error: $e');
      }
      return false;
    }
  }
}
