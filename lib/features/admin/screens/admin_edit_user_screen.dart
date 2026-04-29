import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

class AdminEditUserScreen extends StatefulWidget {
  final DocumentSnapshot user;

  const AdminEditUserScreen({super.key, required this.user});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;
  String? _profileImageUrl;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.user.data() as Map<String, dynamic>;
    final fullName = data['name'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: data['email']);
    _roleController = TextEditingController(text: data['role']);
    _phoneController = TextEditingController(text: data['phone'] ?? '');
    _profileImageUrl = data['profileImageUrl'];
    _isActive = data['isActive'] ?? true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                'Modifier l\'utilisateur',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006F1D),
                ),
              ),
            ],
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
        child: Form(
          key: _formKey,
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
              _buildTextField(
                label: 'Adresse e-mail',
                controller: _emailController,
                hint: 'exemple@ecole-everbloom.fr',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Numéro de téléphone (optionnel)',
                controller: _phoneController,
                hint: 'Ex: 06 12 34 56 78',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Rôle',
                controller: _roleController,
                hint: 'Ex: Enseignant',
                icon: Icons.badge_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 24),
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
            ],
          ),
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
    bool readOnly = false,
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
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
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
                  validator: (value) {
                    if (label == 'Prénom' && (value == null || value.isEmpty)) {
                      return 'Le prénom est obligatoire';
                    }
                    if (label == 'Nom de famille' &&
                        (value == null || value.isEmpty)) {
                      return 'Le nom de famille est obligatoire';
                    }
                    if (label == 'Adresse e-mail' &&
                        (value == null || !value.contains('@'))) {
                      return 'Email valide requis';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006F1D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _handleUpdateUser,
        child: const Text(
          'Mettre à jour',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName';
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      if (_image != null) {
        _profileImageUrl = await _uploadImage(_image!, widget.user.id);
      }

      final updateData = {
        'name': fullName,
        'email': email,
        'phone': phone.isNotEmpty ? phone : null,
        'profileImageUrl': _profileImageUrl,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await widget.user.reference.update(updateData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Utilisateur mis à jour avec succès'),
          backgroundColor: const Color(0xFF006F1D),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      print(e);
      return null;
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
                : (_profileImageUrl != null
                      ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.add_a_photo,
                          color: Color(0x66546259),
                          size: 50,
                        )),
          ),
        ),
      ],
    );
  }
}
