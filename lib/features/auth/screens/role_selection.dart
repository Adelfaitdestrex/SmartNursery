import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6DBF4A), Color(0xFFB5E48C)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Bouton de retour
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Image des enfants dans le cercle
                Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB8EAF5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/kids.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Titre SmartNursery
                const Text(
                  'Smart Nursery',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Bouton je suis un parent
                RoleButton(
                  label: 'je suis un parent',
                  color: const Color(0xFF4FC3F7),
                  imagePath: 'assets/images/parent.png',
                  onTap: () {
                    // Navigator.pushNamed(context, '/parent');
                  },
                ),
                const SizedBox(height: 20),
                // Bouton je suis un.e enseignant.e
                RoleButton(
                  label: 'je suis un.e\nenseignant.e',
                  color: const Color(0xFFF5A623),
                  imagePath: 'assets/images/teacher.png',
                  onTap: () {
                    // Navigator.pushNamed(context, '/teacher');
                  },
                ),
                const SizedBox(height: 20),
                // Bouton je suis un membre de la direction
                RoleButton(
                  label: 'je suis un membre\nde la direction',
                  color: const Color(0xFF5DBE4A),
                  imagePath: 'assets/images/director.png',
                  onTap: () {
                    // Navigator.pushNamed(context, '/director');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Widget RoleButton réutilisable ----
class RoleButton extends StatelessWidget {
  final String label;
  final Color color;
  final String imagePath;
  final VoidCallback onTap;

  const RoleButton({
    Key? key,
    required this.label,
    required this.color,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image de la personne
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 15),
            // Texte du bouton
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
