import 'package:flutter/material.dart';
class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({super.key});

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
                  const Text(
                    "Profil de Léo",
                    style: TextStyle(
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
                  const Text(
                    "Léo",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    "2 ans",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF486912),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Groupe Coccinelle • Plein Temps",
                    style: TextStyle(color: Colors.grey[700]),
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
                        onPressed: () {
                          // action plan alimentaire
                        },
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
              {"label": "Date de naissance", "value": "14 Mars 2022"},
              {"label": "Langue", "value": "Français"},
              {"label": "Sexe", "value": "Masculin"},
            ]),

            const SizedBox(height: 24),

            // INFOS MEDICALES
            _buildInfoCard("Infos Médicales", [
              {"label": "Allergies", "value": "Arachides, Produits laitiers"},
              {"label": "Groupe sanguin", "value": "A+"},
              {"label": "Pédiatre", "value": "Dr. Martin (01 23 45 67 89)"},
            ]),

            const SizedBox(height: 24),

            // PARENTS
            _buildInfoCard("Parents", [
              {"label": "Sophie Laurent", "value": "Maman • Contact Principal"},
              {"label": "Thomas Laurent", "value": "Papa • Contact d’urgence"},
            ]),

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
}