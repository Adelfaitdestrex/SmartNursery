import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddChildScreen extends StatefulWidget {
  const AdminAddChildScreen({super.key});

  @override
  State<AdminAddChildScreen> createState() => _AdminAddChildScreenState();
}

class _AdminAddChildScreenState extends State<AdminAddChildScreen> {
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _medicalInfoController = TextEditingController();

  String _selectedGender = 'Garçon';
  bool _isLoading = false; // Ajout d'un état de chargement

  @override
  void dispose() {
    _childNameController.dispose();
    _birthDateController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }

  // --- FONCTION D'ENREGISTREMENT DANS FIREBASE ---
  Future<void> _sauvegarderEnfant() async {
    if (_childNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nom de l\'enfant')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Séparation du nom complet en Prénom / Nom
      List<String> nameParts = _childNameController.text.trim().split(' ');
      String prenom = nameParts.isNotEmpty ? nameParts.first : '';
      String nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // 2. Création d'une référence avec un ID unique généré automatiquement
      DocumentReference nouvelEnfantRef = FirebaseFirestore.instance.collection('enfants').doc();
      String childId = nouvelEnfantRef.id;

      // 3. Attribution d'une image par défaut selon le genre (temporaire, en attendant le vrai picker photo)
      String defaultImage = _selectedGender == 'Garçon'
          ? 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-garcon-mignon_23-2151199341.jpg'
          : 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-fille-mignonne_23-2151211110.jpg';

      // 4. Enregistrement dans la collection 'enfants'
      await nouvelEnfantRef.set({
        'childId': childId,
        'classID': 'class_little_angels', // On l'affecte directement à cette classe
        'firstName': prenom,
        'lastName': nom,
        'gender': _selectedGender == 'Garçon' ? 'M' : 'F',
        'dateOfBirth': _birthDateController.text, // Idéalement à convertir en Timestamp plus tard
        'enrollmentDate': FieldValue.serverTimestamp(),
        'avatarImageUrl': defaultImage,
        'isActive': true,
        'parentIds': ['id_parent_temporaire'], // Lier au vrai système d'auth parent plus tard
        'emergencyContact': {'phone': _phoneController.text},
        'medicalInfo': {'allergies': _medicalInfoController.text},
        'authorizedPickup': [_parentNameController.text],
        'photoGallery': [],
      });

      // 5. Mise à jour de la taille de la classe (Optionnel mais recommandé pour la cohérence)
      await FirebaseFirestore.instance.collection('classes').doc('class_little_angels').update({
        'childrenIds': FieldValue.arrayUnion([childId]),
        'currentsize': FieldValue.increment(1),
      });

      // 6. Succès et retour en arrière
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enfant ajouté avec succès !'),
            backgroundColor: Color(0xFF006F1D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDE0A7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel('Nom de l\'enfant'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _childNameController, hint: 'Entrez le nom complet'),
                      const SizedBox(height: 16),

                      _buildLabel('Date de naissance'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _birthDateController, hint: 'JJ/MM/AAAA', trailingIcon: Icons.calendar_today_outlined),
                      const SizedBox(height: 16),

                      _buildLabel('Genre'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildGenderButton('Garçon', Icons.boy)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGenderButton('Fille', Icons.girl)),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Divider(color: const Color(0xFFDEECE1).withValues(alpha: 0.5), thickness: 1),
                      const SizedBox(height: 24),

                      const Text(
                        'Informations parentales',
                        style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF28352E)),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Nom du parent'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _parentNameController, hint: 'Entrez le nom du parent'),
                      const SizedBox(height: 16),

                      _buildLabel('Téléphone'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _phoneController, hint: '01 23 45 67 89', trailingIcon: Icons.phone_outlined),
                      const SizedBox(height: 16),

                      _buildLabel('Information Médical'),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _medicalInfoController, hint: 'Entrez les information'),
                    ],
                  ),
                ),

                Positioned(
                  top: -64, left: 0, right: 0,
                  child: Center(child: _buildAvatarPicker()),
                ),

                // BOUTON DE SOUMISSION MIS À JOUR
                Positioned(
                  bottom: 32, left: 24, right: 24,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006F1D), Color(0xFF006118)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(0, 10), blurRadius: 15),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _sauvegarderEnfant, // Exécute la fonction ici
                        borderRadius: BorderRadius.circular(48),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white) // Spinner de chargement
                              : const Text(
                            'Ajouter l\'enfant',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFEAFFE2)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 32, bottom: 96, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF02671B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.maybePop(context), child: const Icon(Icons.arrow_back, color: Colors.white, size: 24)),
          const SizedBox(width: 16),
          const Text('Ajouter un enfant', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 128, height: 128,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_a_photo_outlined, color: Color(0xFF546259), size: 34),
              SizedBox(height: 8),
              Text('Ajouter une photo', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF546259))),
            ],
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF006F1D), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF4FBF4), width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(0, 4), blurRadius: 6)],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF546259)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? trailingIcon}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF6F7E75)), border: InputBorder.none))),
          if (trailingIcon != null) Icon(trailingIcon, color: const Color(0xFF02671B), size: 20),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(32),
          border: isSelected ? Border.all(color: const Color(0xFF006F1D).withValues(alpha: 0.2), width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF065F18) : const Color(0xFF546259), size: 20),
            const SizedBox(width: 8),
            Text(gender, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF065F18) : const Color(0xFF546259))),
          ],
        ),
      ),
    );
  }
}