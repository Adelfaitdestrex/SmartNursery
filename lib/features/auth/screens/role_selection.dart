import 'package:flutter/material.dart';
import 'package:smartnursery/features/auth/screens/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                // Logo SmartNursery
                Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB8EAF5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logosmartnursey.png',
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
                  imagePath: 'assets/images/parent_role.png',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                          autoRedirect: false,
                          expectedRole: 'parent',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Bouton je suis un.e enseignant.e
                RoleButton(
                  label: 'je suis un(e)\nenseignant(e)',
                  color: const Color(0xFFF5A623),
                  imagePath: 'assets/images/educateur_role.png',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                          autoRedirect: false,
                          expectedRole: 'educator',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Bouton je suis un membre de la direction
                RoleButton(
                  label: 'je suis un membre\nde la direction',
                  color: const Color(0xFF5DBE4A),
                  imagePath: 'assets/images/directeur-Role.png',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                          autoRedirect: false,
                          expectedRole: 'admin',
                        ),
                      ),
                    );
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
              padding: const EdgeInsets.all(2), // Petit espacement pour le bord
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
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
