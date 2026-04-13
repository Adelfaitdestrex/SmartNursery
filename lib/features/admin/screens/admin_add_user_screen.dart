import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/services/firebase/firebase_services.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool _isLoading = false;
  bool _emailManuallyEdited = false;

  int _selectedRoleIndex = 0;
  final List<String> _roles = ['Parent', 'Enseignant', 'Administrateur'];

  @override
  void initState() {
    super.initState();
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

  void _onNameChanged() {
    setState(() {
      // Only auto-update email if user hasn't manually edited it
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#*';
    final rnd = Random.secure();
    final newPassword = String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
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
    final first = _cleanString(_firstNameController.text);
    final last = _cleanString(_lastNameController.text);
    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return '$last@ecole-everbloom.fr';
    if (last.isEmpty) return '$first@ecole-everbloom.fr';
    return '$first.$last@ecole-everbloom.fr';
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
                    const SizedBox(height: 32),
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
              icon: Icons.badge_outlined,
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



  Future<void> _handleCreateUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prénom et le nom sont obligatoires.'),
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

    setState(() => _isLoading = true);

    final result = await _firebaseServices.createAccountOnSecondaryApp(
      email,
      password,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == null || result.contains(' ') || result.contains('Error') || result.contains('erreur')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Erreur inconnue'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // result is uid
    final uid = result;
    try {
      await _firebaseServices.saveUserData(
        uid,
        firstName,
        lastName,
        email,
        _roles[_selectedRoleIndex],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé, mais erreur lors de la sauvegarde des données.',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Utilisateur créé : $email'),
        backgroundColor: const Color(0xFF006F1D),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
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
