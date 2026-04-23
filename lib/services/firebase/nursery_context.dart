/// Guide pratique : Utiliser la migration Firestore multi-établissements
///
/// Exemple : Créer la collection 'nurserySettings' (si pas déjà existante)
///
/// ```dart
/// await MigrationService.createNurseryMetadata(
///   settingId: 'little_angels_001',
///   nurseryName: 'Little Angels Crèche',
///   address: {'street': '123 Rue de la Crèche', 'city': 'Lyon'},
///   phoneNumber: '+33 4 12 34 56 78',
///   email: 'contact@littleangels.fr',
///   logoUrl: 'https://...',
///   capacity: 100,
///   openingHours: {
///     'monday': '08:00-18:00',
///     'tuesday': '08:00-18:00',
///     // ...
///   },
/// );
/// ```

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NurseryContext {
  static const String defaultNurseryId = 'little_angels_001';

  /// Obtient l'ID de crèche de l'utilisateur actuel
  static Future<String> getCurrentNurseryId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return defaultNurseryId;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      return doc.data()?['nurseryId'] ?? defaultNurseryId;
    } catch (e) {
      print('Erreur lors de la récupération du nurseryId: $e');
      return defaultNurseryId;
    }
  }
}

/// ===================================
/// Exemples de queries mises à jour
/// ===================================

class QueryExamples {
  static final _firestore = FirebaseFirestore.instance;

  /// ❌ ANCIEN CODE (récupère TOUS les enfants de toutes les crèches)
  /// ```dart
  /// final allChildren = await _firestore.collection('enfants').get();
  /// ```

  /// ✅ NOUVEAU CODE (récupère seulement les enfants de cette crèche)
  static Future<List<Map<String, dynamic>>> getChildrenForNursery(
    String nurseryId,
  ) async {
    final snapshot = await _firestore
        .collection('enfants')
        .where('nurseryId', isEqualTo: nurseryId) // ← FILTRE PAR CRÈCHE
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// ✅ Récupérer les classes d'une crèche
  static Future<List<Map<String, dynamic>>> getClassesForNursery(
    String nurseryId,
  ) async {
    final snapshot = await _firestore
        .collection('classes')
        .where('nurseryId', isEqualTo: nurseryId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// ✅ Récupérer les activités d'une crèche
  static Future<List<Map<String, dynamic>>> getActivitiesForNursery(
    String nurseryId,
  ) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('nurseryId', isEqualTo: nurseryId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// ✅ Flux en temps réel (StreamBuilder friendly)
  static Stream<List<Map<String, dynamic>>> watchChildrenForNursery(
    String nurseryId,
  ) {
    return _firestore
        .collection('enfants')
        .where('nurseryId', isEqualTo: nurseryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

/// ===================================
/// Étapes de migration
/// ===================================
///
/// 1️⃣  Créer la collection 'creches' :
///     ```dart
///     await MigrationService.createNurseryMetadata(
///       nurseryId: 'little_angels_001',
///       name: 'Little Angels Crèche',
///       address: '123 Rue de la Crèche',
///       phone: '+33 1 23 45 67 89',
///       maxCapacity: 100,
///     );
///     ```
///
/// 2️⃣  Ajouter nurseryId à toutes les collections :
///     ```dart
///     await MigrationService.migrateAllCollectionsToNursery(
///       nurseryId: 'little_angels_001',
///     );
///     ```
///
/// 3️⃣  Mettre à jour les users pour ajouter nurseryId :
///     ```dart
///     await _firestore
///         .collection('users')
///         .doc(userId)
///         .update({'nurseryId': 'little_angels_001'});
///     ```
///
/// 4️⃣  Remplacer les queries hardcodées par les nouvelles queries
///     qui filtrent par nurseryId
///
/// 5️⃣  Déployer les nouvelles règles Firestore
