import 'package:flutter/material.dart';

class SchoolGalleryScreen extends StatelessWidget {
  const SchoolGalleryScreen({Key? key}) : super(key: key);

  // Liste des images (on utilise des couleurs pour simuler les photos)
  final List<double> imageHeights = const [
    180, // image 1 - grande
    120, // image 2 - petite
    120, // image 3 - petite
    180, // image 4 - grande
    150, // image 5 - moyenne
    150, // image 6 - moyenne
    130, // image 7 - petite
    130, // image 8 - petite
    160, // image 9 - moyenne
    160, // image 10 - moyenne
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- AppBar verte ----
      appBar: AppBar(
        backgroundColor: const Color(0xFF6DBF4A),
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'School Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      backgroundColor: Colors.white,

      // ---- Corps de la page ----
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Colonne gauche ----
              Expanded(
                child: Column(
                  children: [
                    _buildImageCard(180),
                    const SizedBox(height: 10),
                    _buildImageCard(150),
                    const SizedBox(height: 10),
                    _buildImageCard(130),
                    const SizedBox(height: 10),
                    _buildImageCard(160),
                    const SizedBox(height: 10),
                    _buildImageCard(140),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ---- Colonne droite ----
              Expanded(
                child: Column(
                  children: [
                    _buildImageCard(120),
                    const SizedBox(height: 10),
                    _buildImageCard(180),
                    const SizedBox(height: 10),
                    _buildImageCard(150),
                    const SizedBox(height: 10),
                    _buildImageCard(130),
                    const SizedBox(height: 10),
                    _buildImageCard(160),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Méthode pour construire une carte image ----
  Widget _buildImageCard(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade200, width: 1),

          // Remplacez ceci par Image.asset() ou Image.network()
          // quand vous avez de vraies images
          color: Colors.blue.shade50,
        ),
        // Décommentez pour utiliser une vraie image :
        // child: Image.asset(
        //   'assets/images/photo.jpg',
        //   fit: BoxFit.cover,
        // ),
        //
        // Ou pour une image depuis internet :
        // child: Image.network(
        //   'https://example.com/photo.jpg',
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}
