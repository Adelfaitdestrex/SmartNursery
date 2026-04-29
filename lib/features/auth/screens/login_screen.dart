import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/services/firebase/firebase_services.dart';
import 'package:smartnursery/services/session_service.dart' hide debugPrint;
import 'package:smartnursery/features/activities/screens/activities_page.dart';
import 'package:smartnursery/features/auth/screens/reset_password_screen.dart';
import 'package:smartnursery/features/auth/screens/restricted_access.dart';
import 'package:smartnursery/features/auth/screens/role_selection.dart';

class LoginScreen extends StatefulWidget {
  /// Si [autoRedirect] est true (défaut), redirige automatiquement
  /// vers la page principale si une session Firebase est déjà active.
  /// Mettre à false quand on navigue intentionnellement vers le login
  /// (ex: depuis RoleSelectionScreen) pour forcer l'affichage du formulaire.
  final bool autoRedirect;

  /// Rôle attendu pour la connexion. Si spécifié, l'utilisateur doit avoir
  /// ce rôle dans Firestore pour pouvoir se connecter.
  /// Valeurs possibles: 'parent', 'educator', 'admin', 'director'
  final String? expectedRole;

  const LoginScreen({super.key, this.autoRedirect = true, this.expectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    // Ne pas rediriger si autoRedirect est désactivé (navigation intentionnelle
    // vers la page login, ex: depuis RoleSelectionScreen)
    if (!widget.autoRedirect) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ActivitiesPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await _firebaseServices.signInWithEmailAndPassword(
      email,
      password,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      // Connexion réussie - Vérifier le rôle si expectedRole est spécifié
      if (widget.expectedRole != null) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          final userRole = userDoc.data()?['role'] as String?;

          if (userRole != widget.expectedRole) {
            // Le rôle ne correspond pas - Déconnecter et afficher un message d'erreur
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;

            String roleLabel = '';
            switch (widget.expectedRole) {
              case 'parent':
                roleLabel = 'Parent';
                break;
              case 'educator':
                roleLabel = 'Enseignant';
                break;
              case 'admin':
                roleLabel = 'Membre de la direction';
                break;
              default:
                roleLabel = 'utilisateur';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ce compte n\'est pas un compte $roleLabel. Veuillez utiliser le bon compte.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      // Récupérer les données utilisateur et créer une session
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          final userData = userDoc.data();

          // Créer la session avec les données utilisateur
          await SessionService().createSession(
            userId: userId,
            email: email,
            name: userData?['name'] as String?,
            role: userData?['role'] as String?,
            profileImageUrl: userData?['profileImageUrl'] as String?,
            phone: userData?['phone'] as String?,
            isActive: userData?['isActive'] as bool?,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenue ${userData?['name'] ?? 'utilisateur'}!'),
              backgroundColor: const Color(0xFF006F1D),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          debugPrint('Erreur lors de la création de session: $e');
        }
      }

      // Connexion réussie et rôle validé → navigation vers l'application principale
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FeedPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si expectedRole est défini (venant de RoleSelectionScreen),
        // rediriger vers RoleSelectionScreen au lieu de pop normal
        if (widget.expectedRole != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          );
        }
        // Dans tous les cas, bloquer le pop pour éviter de remonter
        // accidentellement vers une page précédente (ex: RoleSelectionScreen)
        return false;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8BC34A), Colors.white],
              stops: [0.3, 0.45],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Bouton de retour
                if (widget.expectedRole != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 40),
                const SizedBox(height: 40),
                Image.asset('assets/images/enfants-jouent.png', height: 180),
                const SizedBox(height: 20),
                const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Champ Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Champ Mot de passe
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/cadenas.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30, top: 10),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Mot de passe oubliée ?',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton Se connecter
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vous n\'avez pas de compte ? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RestrictedAccessScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
