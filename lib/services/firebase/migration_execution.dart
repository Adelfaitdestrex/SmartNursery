/// SCRIPT D'EXÉCUTION RAPIDE - Migrer vers Structure Multi-Établissements
///
/// À exécuter UNE SEULE FOIS !
///
/// Instructions :
/// 1. Copier ce code dans main.dart temporairement
/// 2. Appeler runMigration() dans une fonction admin
/// 3. Vérifier que tout fonctionne
/// 4. Supprimer ce code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/services/firebase/migration_service.dart';

/// ===== FONCTION PRINCIPALE =====
Future<void> runMigration() async {
  print('🔄 DÉBUT DE LA MIGRATION');
  print('═' * 50);

  try {
    // Étape 1 : Créer la collection nurserySettings
    print('\n📝 Étape 1: Création de nurserySettings...');
    await MigrationService.createNurseryMetadata(
      settingId: 'little_angels_001',
      nurseryName: 'Little Angels Crèche',
      address: {'street': 'Chemin de la Crèche', 'city': 'Lyon, France'},
      phoneNumber: '+33 4 12 34 56 78',
      email: 'contact@littleangels.fr',
      logoUrl: '',
      capacity: 100,
      openingHours: {
        'monday': '08:00-18:00',
        'tuesday': '08:00-18:00',
        'wednesday': '08:00-18:00',
        'thursday': '08:00-18:00',
        'friday': '08:00-18:00',
        'saturday': 'Fermé',
        'sunday': 'Fermé',
      },
    );
    print('✅ nurserySettings créé');

    // Étape 2 : Ajouter nurseryId à toutes les collections
    print('\n🔄 Étape 2: Migration des collections existantes...');
    await MigrationService.migrateAllCollectionsToNursery(
      nurseryId: 'little_angels_001',
    );
    print('✅ Toutes les collections ont été migrées');

    // Étape 3 : Ajouter nurseryId à tous les utilisateurs
    print('\n👥 Étape 3: Migration des utilisateurs...');
    await _migrateUsersToNursery('little_angels_001');
    print('✅ Tous les utilisateurs ont été migrés');

    // Étape 4 : Vérification
    print('\n✔️  Étape 4: Vérification...');
    await _verifyMigration();

    print('\n' + '═' * 50);
    print('🎉 MIGRATION TERMINÉE AVEC SUCCÈS !');
    print('═' * 50);
  } catch (e) {
    print('\n❌ ERREUR LORS DE LA MIGRATION : $e');
    rethrow;
  }
}

/// Ajoute nurseryId à tous les users
Future<void> _migrateUsersToNursery(String nurseryId) async {
  final db = FirebaseFirestore.instance;

  final userDocs = await db.collection('users').get();
  print('  - ${userDocs.docs.length} utilisateurs à migrer');

  for (var doc in userDocs.docs) {
    if (!doc.data().containsKey('nurseryId')) {
      await doc.reference.update({'nurseryId': nurseryId});
      print('    ✓ ${doc.id}');
    }
  }
}

/// Vérifie que la migration a fonctionné
Future<void> _verifyMigration() async {
  final db = FirebaseFirestore.instance;
  const nurseryId = 'little_angels_001';

  // Vérifier nurserySettings
  final nurserySettings = await db
      .collection('nurserySettings')
      .doc(nurseryId)
      .get();
  if (nurserySettings.exists) {
    print('  ✓ nurserySettings OK (${nurserySettings.data()!['nurseryName']})');
  } else {
    throw Exception('nurserySettings manquant');
  }

  // Vérifier classes
  final classes = await db
      .collection('classes')
      .where('nurseryId', isEqualTo: nurseryId)
      .get();
  print('  ✓ ${classes.docs.length} classes trouvées');

  // Vérifier enfants
  final enfants = await db
      .collection('enfants')
      .where('nurseryId', isEqualTo: nurseryId)
      .get();
  print('  ✓ ${enfants.docs.length} enfants trouvés');

  // Vérifier users
  final users = await db
      .collection('users')
      .where('nurseryId', isEqualTo: nurseryId)
      .get();
  print('  ✓ ${users.docs.length} utilisateurs trouvés');
}

/// ===== POINT D'ENTRÉE =====
/// À appeler depuis votre interface admin :
///
/// void onClickMigrateButton() async {
///   if (showConfirmationDialog('Voulez-vous vraiment migrer?')) {
///     await runMigration();
///   }
/// }

/// ===== VÉRIFICATION POST-MIGRATION =====
/// À exécuter après la migration pour valider :

Future<void> verifyPostMigration() async {
  print('\n🔍 Vérification post-migration...');

  // Check 1: Tous les enfants ont nurseryId
  final enfantsWithoutNursery = await FirebaseFirestore.instance
      .collection('enfants')
      .where('nurseryId', isEqualTo: null)
      .get();

  if (enfantsWithoutNursery.docs.isEmpty) {
    print('✅ Tous les enfants ont nurseryId');
  } else {
    print('⚠️  ${enfantsWithoutNursery.docs.length} enfants SANS nurseryId !');
  }

  // Check 2: Tous les users ont nurseryId
  final usersWithoutNursery = await FirebaseFirestore.instance
      .collection('users')
      .where('nurseryId', isEqualTo: null)
      .get();

  if (usersWithoutNursery.docs.isEmpty) {
    print('✅ Tous les utilisateurs ont nurseryId');
  } else {
    print('⚠️  ${usersWithoutNursery.docs.length} users SANS nurseryId !');
  }

  print('✅ Vérification terminée');
}

/// ===== ROLLBACK (EN CAS DE PROBLÈME) =====
/// À utiliser SEULEMENT en cas d'erreur grave

Future<void> rollbackMigration() async {
  print('⚠️  ROLLBACK EN COURS...');

  final db = FirebaseFirestore.instance;

  // Supprimer le champ nurseryId de toutes les collections
  final collections = ['classes', 'enfants', 'activities', 'users'];

  for (final collName in collections) {
    final docs = await db.collection(collName).get();
    for (final doc in docs.docs) {
      await doc.reference.update({'nurseryId': FieldValue.delete()});
    }
    print('✓ $collName rollbacked');
  }

  print('✅ Rollback terminé');
}
