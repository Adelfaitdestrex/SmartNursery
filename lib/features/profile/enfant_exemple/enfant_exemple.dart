import 'package:cloud_firestore/cloud_firestore.dart';

// Génère la classe
Future<void> seedLittleAngelsClass() async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('classes').doc('class_little_angels').set({
    'name': 'Little Angels',
    'classId': 'class_little_angels',
    'ageRange': {'min': 5, 'max': 24},
    'capacity': 15,
    'currentsize': 5,
    'color': '0xFF8BC34A',
    'isActive': true,
    'childrenIds': ['id_1', 'id_2', 'id_3', 'id_4', 'id_5'],
    'educatorsIds': ['id_educateur_malti'],
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// Génère les 5 enfants
Future<void> seedEnfantsExemples() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final List<Map<String, dynamic>> listeEnfants = [
    {
      'childId': 'id_1', 'firstName': 'Julina', 'lastName': 'Martin', 'gender': 'F',
      'avatarImageUrl': 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-fille-mignonne_23-2151211110.jpg',
      'classID': 'class_little_angels', 'parentIds': ['parent_1'],
    },
    {
      'childId': 'id_2', 'firstName': 'Jillian', 'lastName': 'Bernard', 'gender': 'M',
      'avatarImageUrl': 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-garcon-mignon_23-2151199341.jpg',
      'classID': 'class_little_angels', 'parentIds': ['parent_2'],
    },
    {
      'childId': 'id_3', 'firstName': 'Raian', 'lastName': 'Dubois', 'gender': 'M',
      'avatarImageUrl': 'https://img.freepik.com/vecteurs-libre/petit-garcon-souriant-illustration-style-dessin-anime_1308-154942.jpg',
      'classID': 'class_little_angels', 'parentIds': ['parent_3'],
    },
    {
      'childId': 'id_4', 'firstName': 'Oliia', 'lastName': 'Leroy', 'gender': 'F',
      'avatarImageUrl': 'https://img.freepik.com/vecteurs-libre/fille-heureuse-personnage-dessin-anime_1308-160533.jpg',
      'classID': 'class_little_angels', 'parentIds': ['parent_4'],
    },
    {
      'childId': 'id_5', 'firstName': 'Haroin', 'lastName': 'Moreau', 'gender': 'M',
      'avatarImageUrl': 'https://img.freepik.com/vecteurs-libre/personnage-dessin-anime-petit-garcon_1308-161680.jpg',
      'classID': 'class_little_angels', 'parentIds': ['parent_5'],
    },
  ];

  for (var enfant in listeEnfants) {
    var ref = firestore.collection('enfants').doc(enfant['childId']);
    batch.set(ref, {
      ...enfant,
      'dateOfBirth': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'enrollmentDate': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }
  await batch.commit();
}