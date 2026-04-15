import 'package:flutter/material.dart';
import 'package:smartnursery/features/A_propos_enfant/Abcence_calendrier.dart';
import 'package:smartnursery/features/A_propos_enfant/gallery.dart';
import 'package:smartnursery/features/A_propos_enfant/details_des_activit%C3%A9es.dart';
import 'package:smartnursery/features/A_propos_enfant/Profil_medical.dart';

// ---- Widget MenuButton réutilisable ----
class MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MenuButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Ajout de Material pour l'effet InkWell
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChildInfoScreen extends StatelessWidget {
  const ChildInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // ---- En-tête ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'À propos de votre\nEnfant',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A3A6A),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 35,
                    ), // Équilibre visuel pour le bouton retour
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ---- Liste des boutons ----
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    MenuButton(
                      label: 'Alimentation',
                      color: const Color(0xFF3AAECC),
                      onTap: () {
                        // Remplacez par la classe correcte de votre import
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const AlimentationScreen()));
                      },
                    ),
                    const SizedBox(height: 20),

                    MenuButton(
                      label: 'Sieste',
                      color: const Color(0xFFE8C93A),
                      onTap: () {
                        // Navigator.pushNamed(context, '/sieste');
                      },
                    ),
                    const SizedBox(height: 20),

                    MenuButton(
                      label: 'Activité',
                      color: const Color(0xFF6DBF4A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Detail(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    MenuButton(
                      label: 'Santé',
                      color: const Color(0xFFE74C3C),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilMedical(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: 'Absentéisme',
                      color: const Color(0xFF3AAECC),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: 'Galerie',
                      color: const Color(0xFF9B59B6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SchoolGalleryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
