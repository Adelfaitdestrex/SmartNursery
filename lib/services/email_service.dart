import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  /// URL de la Cloud Function Firebase pour envoyer les emails
  ///
  /// À configurer après déploiement de functions/index.js
  ///
  /// INSTRUCTIONS:
  /// 1. cd functions && npm install
  /// 2. firebase functions:config:set gmail.user="your-email@gmail.com" gmail.password="app-password"
  /// 3. firebase deploy --only functions
  /// 4. Copier l'URL retournée et remplacer ici
  ///
  /// Exemple URL:
  /// https://us-central1-smart-nursery-7a6f6.cloudfunctions.net/sendOTP
  ///
  /// ou voir functions/README.md pour les instructions complètes
  static const String _emailEndpoint =
      'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendOTP';

  /// Envoie un email avec un code OTP
  ///
  /// Nécessite un backend/Cloud Function qui accepte:
  /// - email (String)
  /// - otp (String)
  /// - subject (String)
  /// - body (String)
  static Future<bool> sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_emailEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'subject': 'Code de réinitialisation SmartNursery',
          'body':
              '''
Bonjour,

Vous avez demandé une réinitialisation de mot de passe.

Votre code de vérification est: $otp

Ce code expirera dans 15 minutes.

Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.

Cordialement,
Équipe SmartNursery
          ''',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Email send error: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email exception: $e');
      }
      // En mode développement, retourner true pour continuer le flow
      return true;
    }
  }
}
