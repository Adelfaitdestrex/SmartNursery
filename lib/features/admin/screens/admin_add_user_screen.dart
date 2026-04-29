import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:smartnursery/features/admin/screens/add_children_flow_page.dart';
import 'package:smartnursery/services/face_recognition_service.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  File? _image;
  XFile? _faceImage;
  bool _hasFaceData = false;
  final ImagePicker _picker = ImagePicker();
  bool _isActive = true;
  bool _isLoading = false;
  bool _emailManuallyEdited = false;
  final FaceRecognitionService _faceService = FaceRecognitionService();
  String _adminNurseryId = '1'; // Par défaut

  final TextEditingController _enfantController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();
  final TextEditingController _numberOfChildrenController =
      TextEditingController();

  int _selectedRoleIndex = 0;
  final List<String> _roles = [
    'Parent',
    'Enseignant',
    'Administrateur',
    'Directeur',
  ];
  final List<String> _roleValues = ['parent', 'educator', 'admin', 'director'];

  @override
  void initState() {
    super.initState();
    _loadAdminNurseryId();
    _generatePassword();
    _firstNameController.addListener(_onNameChanged);
    _lastNameController.addListener(_onNameChanged);
    _emailController.addListener(() {
      // Detect if user manually typed in the email field
      final autoEmail = _buildAutoEmail();
      if (_emailController.text != autoEmail) {
        _emailManuallyEdited = true;
      }
    });
  }

  Future<void> _loadAdminNurseryId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists && mounted) {
          setState(() {
            _adminNurseryId = userDoc['nurseryId'] as String? ?? '1';
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du nurseryId de l\'admin: $e');
    }
  }

  void _onNameChanged() {
    setState(() {
      if (!_emailManuallyEdited) {
        _emailController.text = _buildAutoEmail();
        _emailController.selection = TextSelection.fromPosition(
          TextPosition(offset: _emailController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _enfantController.dispose();
    _classeController.dispose();
    _numberOfChildrenController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#*';
    final rnd = Random.secure();
    final newPassword = String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    setState(() {
      _passwordController.text = newPassword;
      _passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: _passwordController.text.length),
      );
    });
  }

  String _cleanString(String text) {
    var withDiacritics =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    var withoutDiacritics =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

    String temp = text.trim().toLowerCase();
    for (int i = 0; i < withDiacritics.length; i++) {
      temp = temp.replaceAll(
        withDiacritics[i].toLowerCase(),
        withoutDiacritics[i].toLowerCase(),
      );
    }
    temp = temp.replaceAll(' ', '.');
    temp = temp.replaceAll(RegExp(r'[^a-z0-9.]'), '');
    return temp;
  }

  String _buildAutoEmail() {
    final firstName = _cleanString(_firstNameController.text);
    final lastName = _cleanString(_lastNameController.text);
    if (firstName.isEmpty || lastName.isEmpty) return '';
    return '$firstName.$lastName@ecole-everbloom.fr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildFormSection(),
                    const SizedBox(height: 24),
                    _buildRoleSelection(),
                    const SizedBox(height: 24),
                    _buildDynamicFields(),
                    const SizedBox(height: 24),
                    _buildCredentialsSection(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD6E6DB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF006F1D),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ajout d\'utilisateur',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006F1D),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF91F78E), width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://i.pravatar.cc/150?img=47',
                ), // Admin avatar
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF28352E).withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Personnelles',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28352E),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Prénom',
              controller: _firstNameController,
              hint: 'Ex: Marie',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Nom de famille',
              controller: _lastNameController,
              hint: 'Ex: Lefebvre',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Actif'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Numéro de téléphone (optionnel)',
              controller: _phoneController,
              hint: 'Ex: 06 12 34 56 78',
              icon: Icons.phone_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4FBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E6DB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0x66546259), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0x66546259),
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF28352E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rôle de l\'utilisateur',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28352E),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedRoleIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRoleIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF006F1D)
                          : const Color(0xFFECF6ED),
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFD6E6DB)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _roles[index],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFEAFFE2)
                            : const Color(0xFF546259),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_selectedRoleIndex == 0) {
      // Parent
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Nombre d\'enfants à ajouter',
              controller: _numberOfChildrenController,
              hint: 'Ex: 2',
              icon: Icons.child_care,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      );
    } else if (_selectedRoleIndex == 1) {
      // Enseignant
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildTextField(
          label: 'Attribuer une classe à l\'éducateur',
          controller: _classeController,
          hint: 'Sélectionner la classe',
          icon: Icons.class_outlined,
        ),
      );
    }
    return const SizedBox.shrink(); // Admin
  }

  Widget _buildCredentialsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF006F1D),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006F1D).withValues(alpha: 0.2),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: Color(0xFF91F78E), size: 24),
                SizedBox(width: 12),
                Text(
                  'Identifiants',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Email éditable ─────────────────────────────────
            _buildCredentialLabel('Adresse e-mail'),
            const SizedBox(height: 8),
            _buildEditableCredentialField(
              controller: _emailController,
              icon: Icons.alternate_email,
              hint: 'prenom.nom@ecole-everbloom.fr',
              keyboardType: TextInputType.emailAddress,
              trailingWidget: GestureDetector(
                onTap: () {
                  setState(() {
                    _emailManuallyEdited = false;
                    _emailController.text = _buildAutoEmail();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006118),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Mot de passe éditable ──────────────────────────
            _buildCredentialLabel('Mot de passe temporaire'),
            const SizedBox(height: 8),
            _buildEditableCredentialField(
              controller: _passwordController,
              icon: Icons.key_outlined,
              hint: 'Mot de passe',
              keyboardType: TextInputType.visiblePassword,
              trailingWidget: GestureDetector(
                onTap: _generatePassword,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006118),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Vous pouvez modifier les identifiants ou utiliser ceux générés automatiquement.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xCCEAFFE2),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0x99FFFFFF),
      ),
    );
  }

  Widget _buildEditableCredentialField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
    Widget? trailingWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF91F78E), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              cursorColor: const Color(0xFF91F78E),
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Méthode supprimée - La version PRO gère tout côté backend!

  String _generateDefaultAvatarUrl(String name, String email) {
    // Utilise ui-avatars.com pour générer un avatar déterministe à partir du nom
    // Le paramètre 'name' assure que le même nom produit toujours le même avatar
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=0D8ABC&color=fff';
  }

  Future<void> _handleCreateUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final name = '$firstName $lastName';
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final role = _roleValues[_selectedRoleIndex];

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prénom est obligatoire.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom de famille est obligatoire.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse e-mail valide.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int? numberOfChildren;
    if (role == 'parent') {
      numberOfChildren = int.tryParse(_numberOfChildrenController.text.trim());
      if (numberOfChildren == null || numberOfChildren <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez entrer un nombre d'enfants valide."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // ── Étape 1 : Cloud Function createUser (Admin SDK — pas de basculement de session) ──
      debugPrint('☁️ Calling createUser Cloud Function for $email ($role)...');
      final callable = FirebaseFunctions.instance.httpsCallable('createUser');
      final result = await callable.call({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone.isNotEmpty ? phone : null,
        'role': role,
        'isActive': _isActive,
        'nurseryId': _adminNurseryId,
      });

      final newUid = result.data['uid'] as String;
      debugPrint('✅ Cloud Function success — uid: $newUid');

      // ── Étape 2 : upload photo de profil et mise à jour des champs (admin toujours connecté) ──────────
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (role == 'parent') {
        updateData['childrenIds'] = []; // Initialise la liste des enfants
      }

      if (_image != null) {
        _profileImageUrl = await _uploadImage(_image!, newUid);
        if (_profileImageUrl != null) {
          updateData['profileImageUrl'] = _profileImageUrl;
        }
      } else {
        // Assigne un avatar par défaut si pas de photo
        _profileImageUrl = _generateDefaultAvatarUrl(name, email);
        updateData['profileImageUrl'] = _profileImageUrl;
      }

      // Version PRO: Upload visage avec enregistrement encodage
      if (_faceImage != null) {
        final success = await _faceService.registerFaceProWithEncoding(
          newUid,
          _faceImage!,
        );
        if (success) {
          updateData['hasFaceData'] = true;
          updateData['lastFaceRegisteredAt'] = FieldValue.serverTimestamp();
          debugPrint('✅ Encodage facial sauvegardé pour $newUid');
        } else {
          debugPrint('⚠️ Erreur lors de l\'enregistrement du visage');
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUid)
          .set(updateData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur créé : $email'),
          backgroundColor: const Color(0xFF006F1D),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ── Étape 3 : navigation ─────────────────────────────────────────────────
      if (role == 'parent' && numberOfChildren != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddChildrenFlowPage(
              parentId: newUid,
              numberOfChildren: numberOfChildren!,
              nurseryId: _adminNurseryId,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Cloud Function error: [${e.code}] ${e.message}');
      if (!mounted) return;
      String message = e.message ?? 'Erreur lors de la création';
      if (e.code == 'already-exists') {
        message = 'Cet email est déjà utilisé.';
      } else if (e.code == 'permission-denied') {
        message = "Vous n'avez pas les droits nécessaires.";
      } else if (e.code == 'unauthenticated') {
        message = 'Session expirée. Veuillez vous reconnecter.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image de profil',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E6DB)),
            ),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : const Icon(
                    Icons.add_a_photo,
                    color: Color(0x66546259),
                    size: 50,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Section reconnaissance faciale
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasFaceData
                ? const Color(0xFFECF6ED)
                : const Color(0xFFF4FBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasFaceData
                  ? const Color(0xFF88C043)
                  : const Color(0xFFD6E6DB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _hasFaceData
                        ? Icons.face_retouching_natural
                        : Icons.face_retouching_off,
                    color: _hasFaceData
                        ? const Color(0xFF006F1D)
                        : const Color(0xFF546259),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reconnaissance faciale',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF28352E),
                          ),
                        ),
                        Text(
                          _hasFaceData
                              ? 'Visage enregistré ✓'
                              : 'Optionnel - Améliore l\'identification',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _hasFaceData
                                ? const Color(0xFF006F1D)
                                : const Color(0xFF546259),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickFaceImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasFaceData
                        ? const Color(0xFF88C043)
                        : const Color(0xFF006F1D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    _hasFaceData ? Icons.check_circle : Icons.add_a_photo,
                    size: 18,
                  ),
                  label: Text(
                    _hasFaceData ? 'Visage enregistré' : 'Ajouter un visage',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_faceImage != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Photo de visage sélectionnée',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: const Color(0xFF006F1D),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFaceImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _faceImage = pickedFile;
        _hasFaceData = true;
      });
    }
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006F1D),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF006F1D).withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Créer l\'utilisateur',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
