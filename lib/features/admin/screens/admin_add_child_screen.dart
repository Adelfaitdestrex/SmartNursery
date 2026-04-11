import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _childNameController.dispose();
    _birthDateController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDE0A7), // Light green background from Figma
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 60, // Space for the overlapping avatar
                    left: 24,
                    right: 24,
                    bottom: 120, // Space for the submit button
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Child Information Section
                      _buildLabel('Nom de l\'enfant'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _childNameController,
                        hint: 'Entrez le nom complet',
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Date de naissance'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _birthDateController,
                        hint: 'JJ/MM/AAAA',
                        trailingIcon: Icons.calendar_today_outlined,
                      ),
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
                      
                      // Parent Information Section
                      const Text(
                        'Informations parentales',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF28352E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Nom du parent'),
                      const SizedBox(height: 8),
                      _buildTextField(
                          controller: _parentNameController,
                          hint: 'Entrez le nom du parent'),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Téléphone'),
                      const SizedBox(height: 8),
                      _buildTextField(
                          controller: _phoneController,
                          hint: '01 23 45 67 89',
                          trailingIcon: Icons.phone_outlined),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Information Médical'),
                      const SizedBox(height: 8),
                      _buildTextField(
                          controller: _medicalInfoController,
                          hint: 'Entrez les information'),
                    ],
                  ),
                ),
                
                // Overlapping Avatar widget
                Positioned(
                  top: -64,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildAvatarPicker(),
                  ),
                ),
                
                // Bottom Submit Button
                Positioned(
                  bottom: 32,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006F1D), Color(0xFF006118)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 10),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Handle submit logic
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enfant ajouté avec succès et lié au parent.'),
                              backgroundColor: Color(0xFF006F1D),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(48),
                        child: const Center(
                          child: Text(
                            'Ajouter l\'enfant',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEAFFE2),
                            ),
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
      // The background matches Figma: #02671B with a rounded bottom corner
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 32, bottom: 96, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF02671B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Ajouter un enfant',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_a_photo_outlined, color: Color(0xFF546259), size: 34),
              SizedBox(height: 8),
              Text(
                'Ajouter une photo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF546259),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF006F1D),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF4FBF4), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF546259),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? trailingIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF6F7E75),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: const Color(0xFF02671B), size: 20),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: isSelected 
              ? Border.all(color: const Color(0xFF006F1D).withValues(alpha: 0.2), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF065F18) : const Color(0xFF546259),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF065F18) : const Color(0xFF546259),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
