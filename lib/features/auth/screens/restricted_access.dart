import 'package:flutter/material.dart';

class RestrictedAccessScreen extends StatelessWidget {
  const RestrictedAccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Accès à l'application",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // ---- Icône maison dans carré arrondi ---
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Color(0xFF4CAF50),
                  size: 38,
                ),
              ),
              const SizedBox(height: 15),
              // ---- Titre SmartNursery ----
              const Text(
                'SmartNursery',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
              // ---- Icône clé dans cercle vert clair ----
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF0DF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: Color(0xFF4CAF50),
                  size: 28,
                ),
              ),
              const SizedBox(height: 25),
              // ---- Premier paragraphe avec "code d'accès" cliquable ----
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Pour accéder à l'application de la crèche, vous devez disposer d'un ",
                    ),
                    TextSpan(
                      text: "code d'accès",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: " fourni par la direction de votre crèche."),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ---- Deuxième paragraphe ----
              const Text(
                "Si votre crèche est déjà inscrite sur notre plateforme, veuillez contacter la direction pour recevoir votre code personnel de connexion.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              // ---- Troisième paragraphe (gris clair) ----
              const Text(
                "Ce code vous permettra de créer votre compte parent et d'accéder au suivi quotidien de votre enfant.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              // ---- Carte verte claire ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icône "?" dans cercle vert
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Texte de la carte
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vous n'avez pas de code ?",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Contactez la direction de votre crèche ou demandez à l'accueil lors de votre prochaine visite.",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // ---- Séparateur ----
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 10),
              // ---- Lien "Retour à la connexion" ----
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Retour à la connexion',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
