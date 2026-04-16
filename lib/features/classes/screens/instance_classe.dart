import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/features/classes/screens/calendier_abscence.dart';
// --- POINT D'ENTRÉE DE L'APPLICATION ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartNurseryApp());
}

class SmartNurseryApp extends StatelessWidget {
  const SmartNurseryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartNursery',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SmartNurseryClassPage(),
    );
  }
}

// --- FONCTION D'INJECTION DE DONNÉES ---
Future<void> seedLittleAngelsClass() async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('classes').doc('class_little_angels').set({
    'name': 'Little Angels',
    'classId': 'class_little_angels',
    'ageRange': {
      'min': 5,
      'max': 24,
    },
    'capacity': 15,
    'currentsize': 5,
    'color': '0xFF8BC34A',
    'isActive': true,
    'childrenIds': [
      'id_enfant_1',
      'id_enfant_2',
      'id_enfant_3',
      'id_enfant_4',
      'id_enfant_5'
    ],
    'educatorsIds': ['id_educateur_malti'],
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// --- PAGES SECONDAIRES ---
class AbsencePage extends StatelessWidget {
  final String enfantNom;
  const AbsencePage({Key? key, required this.enfantNom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Absence : $enfantNom"), backgroundColor: const Color(0xFF8BC34A)),
      body: const Center(child: Text("Formulaire de saisie d'absence")),
    );
  }
}

class IncidentPage extends StatelessWidget {
  final String enfantNom;
  const IncidentPage({Key? key, required this.enfantNom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Incident : $enfantNom"), backgroundColor: Colors.redAccent),
      body: const Center(child: Text("Rapport d'incident technique ou médical")),
    );
  }
}

// --- PAGE PRINCIPALE DE LA CLASSE ---
class SmartNurseryClassPage extends StatefulWidget {
  const SmartNurseryClassPage({Key? key}) : super(key: key);

  @override
  _SmartNurseryClassPageState createState() => _SmartNurseryClassPageState();
}

class _SmartNurseryClassPageState extends State<SmartNurseryClassPage> {
  String _searchQuery = "";

  final List<String> _sampleImages = [
    "https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-garcon-mignon_23-2151199341.jpg",
    "https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-fille-mignonne_23-2151211110.jpg",
    "https://img.freepik.com/vecteurs-libre/petit-garcon-souriant-illustration-style-dessin-anime_1308-154942.jpg",
    "https://img.freepik.com/vecteurs-libre/fille-heureuse-personnage-dessin-anime_1308-160533.jpg",
    "https://img.freepik.com/vecteurs-libre/personnage-dessin-anime-petit-garcon_1308-161680.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7E8B8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        title: const Text('Little Angels', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('enfants').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("En attente de données Firestore..."));
                }

                var filteredDocs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var nom = (data['nom'] ?? '').toString().toLowerCase();
                  var prenom = (data['prenom'] ?? '').toString().toLowerCase();
                  return nom.contains(_searchQuery) || prenom.contains(_searchQuery);
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _buildChildCard(
                      context: context,
                      nom: data['nom'] ?? "Nom",
                      prenom: data['prenom'] ?? "Prénom",
                      imageUrl: data['imageUrl'] ?? _sampleImages[index % 5],
                      parentId: data['idparent'] ?? "ID_PARENT",
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Rechercher un enfant...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildChildCard({
    required BuildContext context,
    required String nom,
    required String prenom,
    required String imageUrl,
    required String parentId,
  }) {
    return GestureDetector(
      // Navigation vers votre page CalendarPage existante
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Assurez-vous que votre CalendarPage accepte ce paramètre,
            // sinon retirez "(enfantNom: "$prenom $nom")"
            builder: (context) => CalendarPage()
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(imageUrl),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.mail, size: 16, color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(prenom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(nom, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}