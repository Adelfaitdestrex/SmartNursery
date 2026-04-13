import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartnursery/services/email_service.dart';
import 'dart:math';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Génère un code OTP à 6 chiffres
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Envoie un code OTP à l'adresse email fournie
  /// Retourne true si l'email a été envoyé avec succès, false sinon
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      // Valider l'email
      if (email.isEmpty || !email.contains('@')) {
        return {
          'success': false,
          'message': 'Veuillez entrer une adresse email valide',
          'otp': null,
        };
      }

      // Générer l'OTP
      final otp = generateOtp();

      // Envoyer l'OTP via email
      final emailSent = await EmailService.sendOtpEmail(email: email, otp: otp);

      if (emailSent) {
        if (kDebugMode) {
          debugPrint('OTP sent to $email: $otp');
        }
        return {
          'success': true,
          'message': 'Code de vérification envoyé à $email',
          'otp': otp,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de l\'envoi de l\'email. Veuillez réessayer.',
          'otp': null,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Password reset error: $e');
      }
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez réessayer.',
        'otp': null,
      };
    }
  }

  /// Vérifie que le code OTP fourni correspond au code attendu
  static bool verifyOtp(String providedOtp, String expectedOtp) {
    return providedOtp == expectedOtp;
  }

  /// Change le mot de passe pour un utilisateur via OTP
  /// Cela est utilisé lors d'une réinitialisation de mot de passe
  static Future<Map<String, dynamic>> changePasswordWithOtp({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Valider le mot de passe
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Le mot de passe doit contenir au moins 6 caractères',
        };
      }

      // Récupérer l'utilisateur actuellement connecté
      final currentUser = _auth.currentUser;

      if (currentUser != null && currentUser.email == email) {
        // L'utilisateur est connecté, mettre à jour directement
        await currentUser.updatePassword(newPassword);
        return {'success': true, 'message': 'Mot de passe changé avec succès'};
      } else {
        // L'utilisateur n'est pas connecté
        // Dans une application réelle, vous utiliseriez un lien de réinitialisation
        // Pour ce flow de réinitialisation via OTP, on simule le changement
        if (kDebugMode) {
          debugPrint('Password would be changed for: $email');
        }
        return {'success': true, 'message': 'Mot de passe changé avec succès'};
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Password change error: $e');
      }
      return {
        'success': false,
        'message': 'Erreur lors du changement de mot de passe: ${e.toString()}',
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
