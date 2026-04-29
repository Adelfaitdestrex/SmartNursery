import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilMedical extends StatelessWidget {
  final ChildModel child;
  const ProfilMedical({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER avec bouton flèche
            Container(
              width: double.infinity,
              height: 114,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7CA62D), Color(0xFF4B651B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFF749B2B),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  Text(
                    "Profil de ${child.firstName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // HERO PROFILE CARD avec boutons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage("assets/icons/avatar-logo.png.png"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    child.firstName,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _calculateAge(child.dateOfBirth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF486912),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<DocumentSnapshot>(
                    future: child.classId != null ? FirebaseFirestore.instance.collection('classes').doc(child.classId).get() : null,
                    builder: (context, snapshot) {
                      String className = 'Aucune classe';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        className = snapshot.data!.get('name') ?? 'Classe inconnue';
                      }
                      return Text(
                        className,
                        style: TextStyle(color: Colors.grey[700]),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Boutons Dossier Complet et Plan Alimentaire
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9EF93),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // action dossier complet
                          },
                        child: const Text(
                          "Dossier Complet",
                          style: TextStyle(color: Color(0xFF3C5A0F)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7F08B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _showMealPlanDialog(context),
                        child: const Text(
                          "Plan Alimentaire",
                          style: TextStyle(color: Color(0xFF3B5B02)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DETAILS PERSONNELS
            _buildInfoCard("Détails Personnels", [
              {"label": "Date de naissance", "value": DateFormat('dd MMMM yyyy', 'fr_FR').format(child.dateOfBirth)},
              {"label": "Sexe", "value": child.gender},
            ]),

            const SizedBox(height: 24),

            // INFOS MEDICALES
            _buildInfoCard("Infos Médicales", [
              {"label": "Allergies", "value": child.allergies.isNotEmpty ? child.allergies.join(", ") : "Aucune"},
              {"label": "Maladies", "value": (child.medicinalInfo?['maladies'] as List?)?.join(', ') ?? "Aucune"},
            ]),

            const SizedBox(height: 24),

            // PARENTS
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: child.parentIds.isNotEmpty ? child.parentIds : ['none']).get(),
              builder: (context, snapshot) {
                List<Map<String, String>> parentItems = [];
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    parentItems.add({
                      "label": "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                      "value": data['role'] ?? 'Parent',
                    });
                  }
                }
                if (parentItems.isEmpty) {
                  parentItems.add({"label": "Aucun parent", "value": "-"});
                }
                return _buildInfoCard("Parents", parentItems);
              },
            ),

            const SizedBox(height: 24),

            // JOURNAL HIGHLIGHTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Points forts du journal\n quotidien",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: Text("Voir \ntout")),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: PageView(
                controller: PageController(viewportFraction: 0.9),
                children: [
                  _buildHighlightCard(
                    title: "REPAS",
                    subtitle: "L'heure du délicieux déjeuner",
                    description: "Léo a adoré les carottes aujourd'hui !",
                    image: "assets/icons/cafeteria.png",
                  ),
                  _buildHighlightCard(
                    title: "SOMMEIL",
                    subtitle: "Sieste de l'après-midi",
                    description: "Un sommeil calme de 1h30 sans interruption.",
                    image: "assets/images/little-cute-girl-bed-with-toy.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INFO CARD BUILDER
  Widget _buildInfoCard(String title, List<Map<String, String>> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5EC),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item["label"]!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item["value"]!,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HIGHLIGHT CARD BUILDER
  Widget _buildHighlightCard({
    required String title,
    required String subtitle,
    required String description,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Image.asset(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    
    if (age == 0) {
      int months = currentDate.month - birthDate.month;
      if (months < 0) months += 12;
      return "$months mois";
    }
    return "$age ans";
  }

  void _showMealPlanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Plan Alimentaire",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3B5B02)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('enfants')
                        .doc(child.childId)
                        .collection('meal_requests')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Erreur: ${snapshot.error}"));
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Aucun repas n'a été réservé pour l'instant.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final mealName = data['mealName'] ?? 'Repas inconnu';
                          final dateStr = data['date'] ?? ''; 
                          
                          // Convert YYYY-MM-DD to standard format
                          String formattedDate = dateStr;
                          try {
                            final parsedDate = DateTime.parse(dateStr);
                            formattedDate = DateFormat('EEEE dd MMMM', 'fr_FR').format(parsedDate);
                            // capitalize first letter
                            formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
                          } catch (_) {}

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5EC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.restaurant_menu, color: Color(0xFF486912)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mealName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}