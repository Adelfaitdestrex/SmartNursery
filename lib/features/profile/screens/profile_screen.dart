import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smartnursery/features/settings/screens/settings_page.dart';
import 'package:smartnursery/features/admin/screens/admin_redirection_screen.dart';
import 'package:smartnursery/features/auth/screens/login_screen.dart';
import 'package:smartnursery/services/session_service.dart';
import 'package:smartnursery/features/A_propos_enfant/redirection_info_enfant.dart';
import 'package:smartnursery/features/reconnaissancefaciale/recherche.dart';
import 'package:smartnursery/services/face_recognition_service.dart';
import 'package:smartnursery/features/A_propos_enfant/services/child_service.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E8E2), Color(0xFFA4CF53), Color(0xFFE0E6E2)],
            stops: [0.0, 0.23558, 0.47115],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 18),
                const _Header(),
                const SizedBox(height: 18),
                const _TopActions(),
                const SizedBox(height: 22),
                const _MainProfileCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, color: Color(0xFFFFD700), size: 44),
            SizedBox(width: 10),
            Text(
              'Mon profil',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Color(0xCC000000),
                shadows: [
                  Shadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.emoji_emotions_outlined, color: Colors.orange, size: 38),
          ],
        ),
        SizedBox(height: 6),
        Text(
          'Modifiez facilement vos information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0x4D000000),
          ),
        ),
      ],
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 93,
              decoration: BoxDecoration(
                color: const Color(0xFF89B832),
                borderRadius: BorderRadius.circular(60),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 28, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Mon\nprofil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 24,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Paramétres',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainProfileCard extends StatelessWidget {
  const _MainProfileCard();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF89B832)),
        ),
        child: const Text('Utilisateur non connecté'),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF89B832)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? <String, dynamic>{};
            final firstName = (data['firstName'] ?? '').toString();
            final lastName = (data['lastName'] ?? '').toString();
            final roleRaw = (data['role'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? currentUser.email ?? '').toString();

            String roleLabel;
            switch (roleRaw) {
              case 'admin':
                roleLabel = 'Administrateur';
                break;
              case 'director':
                roleLabel = 'Directeur';
                break;
              case 'educator':
              case 'educateur':
                roleLabel = 'Educateur';
                break;
              case 'parent':
                roleLabel = 'Parent';
                break;
              default:
                roleLabel = roleRaw.isEmpty ? 'Non défini' : roleRaw;
            }

            final displayFirstName = firstName.isEmpty
                ? 'Utilisateur'
                : firstName;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $displayFirstName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F7607),
                  ),
                ),
                const SizedBox(height: 16),
                if (roleRaw == 'parent')
                  StreamBuilder<List<ChildModel>>(
                    stream: ChildService().getChildrenByParentStream(
                      currentUser.uid,
                    ),
                    builder: (context, childSnapshot) {
                      if (childSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (childSnapshot.hasError) {
                        return const Text('Erreur de chargement des enfants');
                      }
                      final children = childSnapshot.data ?? [];
                      if (children.isEmpty) {
                        return const Text(
                          'Aucun enfant associé',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Column(
                        children: children
                            .map(
                              (child) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _ChildCard(child: child),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                if (roleRaw != 'parent')
                  const Text(
                    'Profil personnel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 24),
                _InfoField(
                  label: 'Nom',
                  value: lastName.isEmpty ? 'Non renseigné' : lastName,
                  iconData: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'Prénom',
                  value: firstName.isEmpty ? 'Non renseigné' : firstName,
                  iconData: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'Rôle',
                  value: roleLabel,
                  iconData: Icons.shield_outlined,
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'Email',
                  value: email.isEmpty ? 'Non renseigné' : email,
                  iconData: Icons.mail_outline,
                ),
                const SizedBox(height: 24),
                _FaceRecognitionAccessButton(role: roleRaw),
                _IdentifyUserByFaceButton(role: roleRaw),
                _AddFaceToFirebaseButton(role: roleRaw),
                if (roleRaw == 'admin') ...[
                  const SizedBox(height: 12),
                  _CustomButton(
                    text: 'Admin Mode',
                    backgroundColor: const Color(0xFFB20000),
                    textColor: Colors.white,
                    borderColor: const Color(0xFF8FBC3B),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                _CustomButton(
                  text: 'Déconnecté',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFFB20000),
                  borderColor: const Color(0xFFBC3B3B),
                  iconData: Icons.logout,
                  onTap: () async {
                    // Affiche une demande de confirmation avant déconnexion
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirmer la déconnexion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB20000),
                            ),
                          ),
                          content: const Text(
                            'Êtes-vous sûr de vouloir vous déconnecter ?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF333333),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Déconnecté',
                                style: TextStyle(
                                  color: Color(0xFFB20000),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // Procède à la déconnexion si confirmée
                    if (confirmed == true) {
                      // Effacer la session avant de se déconnecter
                      await SessionService().clearSession();

                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FaceRecognitionAccessButton extends StatelessWidget {
  final String role;

  const _FaceRecognitionAccessButton({required this.role});

  @override
  Widget build(BuildContext context) {
    final canAccess =
        role == 'admin' || role == 'educateur' || role == 'educator';

    if (!canAccess) {
      return const SizedBox.shrink();
    }

    return _CustomButton(
      text: 'Reconnaissance Faciale',
      backgroundColor: const Color(0xFF88C043),
      textColor: Colors.white,
      borderColor: const Color(0xFF88C043),
      iconData: Icons.face_retouching_natural,
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RechercheFacePage()));
      },
    );
  }
}

class _IdentifyUserByFaceButton extends StatefulWidget {
  final String role;

  const _IdentifyUserByFaceButton({required this.role});

  @override
  State<_IdentifyUserByFaceButton> createState() =>
      _IdentifyUserByFaceButtonState();
}

class _IdentifyUserByFaceButtonState extends State<_IdentifyUserByFaceButton> {
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final ImagePicker _picker = ImagePicker();
  bool _isIdentifying = false;

  @override
  Widget build(BuildContext context) {
    final canAccess =
        widget.role == 'admin' ||
        widget.role == 'educateur' ||
        widget.role == 'educator';

    if (!canAccess) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        _CustomButton(
          text: _isIdentifying
              ? 'Identification en cours...'
              : 'Identifier un utilisateur',
          backgroundColor: const Color(0xFF007AFF),
          textColor: Colors.white,
          borderColor: const Color(0xFF007AFF),
          iconData: Icons.face_unlock_outlined,
          onTap: _isIdentifying ? () {} : _identifyUser,
        ),
      ],
    );
  }

  Future<void> _identifyUser() async {
    // 📷 Sélectionner une image depuis la galerie
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identification annulée: aucune image sélectionnée'),
        ),
      );
      return;
    }

    setState(() {
      _isIdentifying = true;
    });

    try {
      // 🔍 Appeler le service d'identification
      final result = await _faceService.identifyUserFromAllFaces(
        File(image.path),
      );

      if (!mounted) return;

      // ✅ Afficher le résultat
      _showIdentificationResult(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isIdentifying = false;
        });
      }
    }
  }

  void _showIdentificationResult(FaceIdentificationResult result) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                result.identified ? Icons.check_circle : Icons.cancel,
                color: result.identified ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                result.identified
                    ? 'Utilisateur identifié ✅'
                    : 'Identification échouée ❌',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.identified) ...[
                Text(
                  'Nom: ${result.userDisplayName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Rôle: ${result.userRole}'),
                const SizedBox(height: 8),
                Text(
                  'Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Text(
                  'Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: result.confidence > 0.5 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result.identified ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: result.identified
                        ? Colors.green[200]!
                        : Colors.red[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: result.identified
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

class _AddFaceToFirebaseButton extends StatefulWidget {
  final String role;

  const _AddFaceToFirebaseButton({required this.role});

  @override
  State<_AddFaceToFirebaseButton> createState() =>
      _AddFaceToFirebaseButtonState();
}

class _AddFaceToFirebaseButtonState extends State<_AddFaceToFirebaseButton> {
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final canAccess =
        widget.role == 'admin' ||
        widget.role == 'educateur' ||
        widget.role == 'educator';

    if (!canAccess) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        _CustomButton(
          text: _isUploading
              ? 'Ajout en cours...'
              : 'Ajouter un visage autorise',
          backgroundColor: Colors.white,
          textColor: const Color(0xFF2F5D00),
          borderColor: const Color(0xFF88C043),
          iconData: Icons.add_a_photo_outlined,
          onTap: _isUploading ? () {} : _addFace,
        ),
      ],
    );
  }

  Future<void> _addFace() async {
    final userMatch = await _askAuthorizedUser();
    if (userMatch == null || !mounted) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajout annulé: aucune image sélectionnée'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final success = await _faceService.registerFaceFromXFile(
      userMatch.uid,
      image,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Visage ajouté avec succès pour ${userMatch.displayName}'
              : 'Echec: impossible d\'ajouter le visage',
        ),
      ),
    );
  }

  Future<FaceUserMatch?> _askAuthorizedUser() async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    final shouldSearch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter un visage autorise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prenom'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );

    if (shouldSearch != true) {
      firstNameController.dispose();
      lastNameController.dispose();
      return null;
    }

    final matches = await _faceService.findAuthorizedUsersByName(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
    );

    firstNameController.dispose();
    lastNameController.dispose();

    if (!mounted) return null;

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun utilisateur autorise trouve')),
      );
      return null;
    }

    if (matches.length == 1) {
      return matches.first;
    }

    return showDialog<FaceUserMatch>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choisir un utilisateur'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: matches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  title: Text(match.displayName),
                  subtitle: Text(match.role),
                  onTap: () => Navigator.of(dialogContext).pop(match),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;

  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    // Calcul de l'âge
    final today = DateTime.now();
    int age = today.year - child.dateOfBirth.year;
    if (today.month < child.dateOfBirth.month ||
        (today.month == child.dateOfBirth.month &&
            today.day < child.dateOfBirth.day)) {
      age--;
    }
    final ageText = age > 0
        ? '$age ans'
        : '${today.difference(child.dateOfBirth).inDays ~/ 30} mois';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChildInfoScreen(child: child)),
        );
      },
      child: Container(
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFE4F3C9), Color(0xFF89B832)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              backgroundImage: child.photoGallery.isNotEmpty
                  ? NetworkImage(child.photoGallery.first)
                  : null,
              child: child.photoGallery.isEmpty
                  ? const Icon(Icons.face, size: 50, color: Color(0xFF89B832))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    child.firstName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ageText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF5F5F5),
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  if (child.classId != null && child.classId!.isNotEmpty)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('classes')
                          .doc(child.classId)
                          .get(),
                      builder: (context, snapshot) {
                        String className = 'Chargement...';
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            className = data?['name'] ?? child.classId!;
                          } else {
                            className = 'Classe introuvable';
                          }
                        }
                        return Text(
                          className,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF5F5F5),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData iconData;

  const _InfoField({
    required this.label,
    required this.value,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4F7607),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Icon(iconData, size: 22, color: const Color(0xFF89B832)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? iconData;
  final VoidCallback onTap;

  const _CustomButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null) ...[
                Icon(iconData, color: textColor, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
