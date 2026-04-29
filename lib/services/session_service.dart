import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de session utilisateur
/// Stocke et récupère les informations de session après connexion
class SessionService {
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _profileImageUrlKey = 'user_profile_image_url';
  static const String _phoneKey = 'user_phone';
  static const String _isActiveKey = 'user_is_active';
  static const String _loginTimeKey = 'login_time';

  late SharedPreferences _prefs;
  static final SessionService _instance = SessionService._internal();

  factory SessionService() {
    return _instance;
  }

  SessionService._internal();

  /// Initialise le service avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Crée une session utilisateur avec les informations fournies
  Future<void> createSession({
    required String userId,
    required String email,
    String? name,
    String? role,
    String? profileImageUrl,
    String? phone,
    bool? isActive,
  }) async {
    try {
      await Future.wait([
        _prefs.setString(_userIdKey, userId),
        _prefs.setString(_emailKey, email),
        if (name != null) _prefs.setString(_nameKey, name),
        if (role != null) _prefs.setString(_roleKey, role),
        if (profileImageUrl != null)
          _prefs.setString(_profileImageUrlKey, profileImageUrl),
        if (phone != null) _prefs.setString(_phoneKey, phone),
        if (isActive != null) _prefs.setBool(_isActiveKey, isActive),
        _prefs.setString(_loginTimeKey, DateTime.now().toIso8601String()),
      ]);
      debugPrint('✅ Session créée pour l\'utilisateur: $userId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la création de la session: $e');
      rethrow;
    }
  }

  /// Récupère l'ID de l'utilisateur connecté
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Récupère l'email de l'utilisateur connecté
  String? getEmail() {
    return _prefs.getString(_emailKey);
  }

  /// Récupère le nom de l'utilisateur connecté
  String? getName() {
    return _prefs.getString(_nameKey);
  }

  /// Récupère le rôle de l'utilisateur connecté
  String? getRole() {
    return _prefs.getString(_roleKey);
  }

  /// Récupère l'URL de la photo de profil
  String? getProfileImageUrl() {
    return _prefs.getString(_profileImageUrlKey);
  }

  /// Récupère le téléphone de l'utilisateur
  String? getPhone() {
    return _prefs.getString(_phoneKey);
  }

  /// Récupère si l'utilisateur est actif
  bool? isUserActive() {
    return _prefs.getBool(_isActiveKey);
  }

  /// Récupère l'heure de connexion
  String? getLoginTime() {
    return _prefs.getString(_loginTimeKey);
  }

  /// Récupère toutes les informations de session
  Map<String, dynamic> getSessionData() {
    return {
      'userId': getUserId(),
      'email': getEmail(),
      'name': getName(),
      'role': getRole(),
      'profileImageUrl': getProfileImageUrl(),
      'phone': getPhone(),
      'isActive': isUserActive(),
      'loginTime': getLoginTime(),
    };
  }

  /// Vérifie si une session est active
  bool isSessionActive() {
    return getUserId() != null && getEmail() != null;
  }

  /// Efface complètement la session (déconnexion)
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _prefs.remove(_userIdKey),
        _prefs.remove(_emailKey),
        _prefs.remove(_nameKey),
        _prefs.remove(_roleKey),
        _prefs.remove(_profileImageUrlKey),
        _prefs.remove(_phoneKey),
        _prefs.remove(_isActiveKey),
        _prefs.remove(_loginTimeKey),
      ]);
      debugPrint('✅ Session effacée');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'effacement de la session: $e');
      rethrow;
    }
  }

  /// Met à jour les informations de session
  Future<void> updateSessionData({
    String? name,
    String? profileImageUrl,
    String? phone,
    bool? isActive,
  }) async {
    try {
      if (name != null) await _prefs.setString(_nameKey, name);
      if (profileImageUrl != null)
        await _prefs.setString(_profileImageUrlKey, profileImageUrl);
      if (phone != null) await _prefs.setString(_phoneKey, phone);
      if (isActive != null) await _prefs.setBool(_isActiveKey, isActive);
      debugPrint('✅ Session mise à jour');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour de la session: $e');
      rethrow;
    }
  }
}

// Fonction de débogage pour imprimer
void debugPrint(String message) {
  print('[SessionService] $message');
}
