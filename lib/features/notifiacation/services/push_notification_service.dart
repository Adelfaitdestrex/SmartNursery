import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer les notifications push FCM
class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialiser le service FCM
  static Future<void> initialize() async {
    try {
      // Demander la permission sur iOS
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      debugPrint('🔔 Permission FCM: ${settings.authorizationStatus}');

      // Récupérer le token FCM pour l'utilisateur
      final token = await _firebaseMessaging.getToken();
      debugPrint('🎫 FCM Token: $token');

      // Configurer les handlers pour les messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '📬 Message reçu en foreground: ${message.notification?.title}',
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📖 App ouverte via notification: ${message.data}');
      });

      // Pour les messages reçus en background, voir main.dart
      debugPrint('✅ Service FCM initialisé');
    } catch (e) {
      debugPrint('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Récupérer le token FCM de l'utilisateur
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Erreur récupération token FCM: $e');
      return null;
    }
  }

  /// Sauvegarder le token FCM pour un utilisateur (pour les notifications cibles)
  static Future<void> saveFCMTokenForUser(String userId, String token) async {
    // Cette méthode sera appelée depuis AuthService pour stocker le token
    // dans Firestore pour envoyer des notifications cibles
    debugPrint('💾 Token FCM à sauvegarder pour $userId: $token');
  }
}
