import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour migrer la structure des collections Firestore
/// Ajoute le champ nurseryId à toutes les collections liées à une crèche
class MigrationService {
  static const String _defaultNurseryId = 'little_angels_001';

  /// Ajoute nurseryId à tous les documents existants
  static Future<void> migrateAllCollectionsToNursery({
    String nurseryId = _defaultNurseryId,
  }) async {
    try {
      print('🔄 Migration vers structure multi-établissements...');

      // Migrer classes
      await _migrateCollection('classes', nurseryId);

      // Migrer enfants
      await _migrateCollection('enfants', nurseryId);

      // Migrer activities
      await _migrateCollection('activities', nurseryId);

      // Migrer meals
      await _migrateCollection('meals', nurseryId);

      // Migrer absences
      await _migrateCollection('absences', nurseryId);

      // Migrer incidents
      await _migrateCollection('incidents', nurseryId);

      print('✅ Migration terminée avec succès !');
    } catch (e) {
      print('❌ Erreur lors de la migration: $e');
      rethrow;
    }
  }

  /// Ajoute nurseryId à tous les documents d'une collection
  static Future<void> _migrateCollection(
    String collectionName,
    String nurseryId,
  ) async {
    try {
      final collection = FirebaseFirestore.instance.collection(collectionName);
      final docs = await collection.get();

      print(
        '  Mise à jour de $collectionName (${docs.docs.length} documents)...',
      );

      for (var doc in docs.docs) {
        if (!doc.data().containsKey('nurseryId')) {
          await doc.reference.update({'nurseryId': nurseryId});
        }
      }

      print('  ✓ $collectionName migré');
    } catch (e) {
      print('  ✗ Erreur lors de la migration de $collectionName: $e');
    }
  }

  /// Met à jour le document 'nurserySettings' existant
  /// Note: utilise la collection existante 'nurserySettings' au lieu de 'creches'
  static Future<void> createNurseryMetadata({
    required String settingId,
    required String nurseryName,
    Map<String, dynamic>? address,
    String? phoneNumber,
    String? email,
    String? logoUrl,
    int? capacity,
    List<String>? admissible,
    Map<String, dynamic>? features,
    Map<String, dynamic>? openingHours,
  }) async {
    await FirebaseFirestore.instance
        .collection('nurserySettings')
        .doc(settingId)
        .set({
          'nurseryId': settingId,
          'nurseryName': nurseryName,
          if (address != null) 'address': address,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (email != null) 'email': email,
          if (logoUrl != null) 'logoUrl': logoUrl,
          if (capacity != null) 'capacity': capacity,
          if (admissible != null) 'admissible': admissible,
          if (features != null) 'features': features,
          if (openingHours != null) 'openingHours': openingHours,
          'updateAtM': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
