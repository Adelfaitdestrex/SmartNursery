import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/admin_profile_avatar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/services/session_service.dart' hide debugPrint;

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedHeader(
              title: 'Paramètres',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () => Navigator.maybePop(context),
              rightWidget: const AdminProfileAvatar(
                size: 36,
                borderColor: Colors.white54,
                borderWidth: 2,
              ),
              onRightTap: () {}, // déjà sur la page settings
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Profile Section
                    const _UserProfileSection(),
                    const SizedBox(height: 32),

                    // Notifications Section
                    const _NotificationsSection(),
                    const SizedBox(height: 32),

                    // Preferences Section
                    const _PreferencesSection(),
                    const SizedBox(height: 32),

                    // Security Section
                    const _SecuritySection(),
                    const SizedBox(height: 32),

                    // Déconnexion Button
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.activityCardRed,
                        size: 18,
                      ),
                      label: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.activityCardRed,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 26,
                        ),
                        side: const BorderSide(
                          color: AppColors.activityCardRed,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatefulWidget {
  const _UserProfileSection();

  @override
  State<_UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<_UserProfileSection> {
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String? _profileImageUrl;
  String? _userRole;
  bool _isLoading = true;
  bool _hasChanges = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _nomController.addListener(() => setState(() => _hasChanges = true));
    _prenomController.addListener(() => setState(() => _hasChanges = true));
    _phoneController.addListener(() => setState(() => _hasChanges = true));

    _loadUserData();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}.jpg');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Mise à jour Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mise à jour de la session locale
      await SessionService().updateSessionData(profileImageUrl: downloadUrl);

      if (!mounted) return;
      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Erreur upload image: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      final userData = userDoc.data() ?? {};
      final fullName = (userData['name'] as String?)?.split(' ') ?? ['', ''];

      setState(() {
        _prenomController.text = fullName.isNotEmpty ? fullName[0] : '';
        _nomController.text = fullName.length > 1
            ? fullName.sublist(1).join(' ')
            : '';
        _emailController.text = currentUser.email ?? '';
        _phoneController.text = (userData['phone'] as String?) ?? '';
        _profileImageUrl = userData['profileImageUrl'] as String?;
        _userRole = userData['role'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final newFullName =
          '${_prenomController.text.trim()} ${_nomController.text.trim()}'
              .trim();
      final newPhone = _phoneController.text.trim();

      // Mise à jour Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'name': newFullName,
            'phone': newPhone.isEmpty ? null : newPhone,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Mise à jour de la session
      await SessionService().updateSessionData(
        name: newFullName,
        phone: newPhone.isEmpty ? null : newPhone,
      );

      if (!mounted) return;

      setState(() => _hasChanges = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickAndUploadImage,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      color: Colors.grey[300],
                      image: _profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImageUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  if (_isUploadingImage)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.headerBottom,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nomController,
                    builder: (context, nomValue, child) {
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _prenomController,
                        builder: (context, prenomValue, child) {
                          return Text(
                            '${prenomValue.text} ${nomValue.text}'.trim(),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userRole ?? '',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.mutedText,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _InfoRow(
                label: 'PRÉNOM',
                controller: _prenomController,
                isFirst: true,
                onTap: () {},
              ),
              const SizedBox(height: 4),
              _InfoRow(label: 'NOM', controller: _nomController, onTap: () {}),
              const SizedBox(height: 4),
              _InfoRow(
                label: 'EMAIL',
                controller: _emailController,
                isReadOnly: true,
                onTap: () {},
              ),
              const SizedBox(height: 4),
              _InfoRow(
                label: 'TÉLÉPHONE',
                controller: _phoneController,
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.headerBottom,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Enregistrer les modifications',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;
  final bool isDefaultIcon;
  final bool isReadOnly;

  const _InfoRow({
    required this.label,
    this.value,
    this.controller,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.isDefaultIcon = true,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isFirst ? 28 : 0),
            bottom: Radius.circular(isLast ? 28 : 0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6F7E75),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller != null)
                    TextFormField(
                      controller: controller,
                      readOnly: isReadOnly,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isReadOnly ? Colors.grey : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      value ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isDefaultIcon ? Icons.edit : Icons.edit,
              size: 16,
              color: isDefaultIcon ? Colors.grey : const Color(0xFF3D5216),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool activeNotifs = true;
  bool presencesNotif = true;
  bool classesNotif = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _SettingSwitchRow(
                iconBackgroundColor: AppColors.bottomNavBackground,
                iconData: Icons.notifications_none_outlined,
                title: 'Activer les notifications',
                value: activeNotifs,
                onChanged: (val) => setState(() => activeNotifs = val),
                isFirst: true,
              ),
              const SizedBox(height: 4),
              _SettingSwitchRow(
                iconBackgroundColor: Colors.transparent,
                hideIcon: true,
                title: 'Notifications des présences',
                value: presencesNotif,
                onChanged: (val) => setState(() => presencesNotif = val),
              ),
              const SizedBox(height: 4),
              _SettingSwitchRow(
                iconBackgroundColor: Colors.transparent,
                hideIcon: true,
                title: 'Notifications des classes',
                value: classesNotif,
                onChanged: (val) => setState(() => classesNotif = val),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatefulWidget {
  const _PreferencesSection();

  @override
  State<_PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<_PreferencesSection> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Préférences',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _SettingNavigationRow(
                iconBackgroundColor: AppColors.bottomNavBackground,
                iconData: Icons.language,
                title: 'Langue',
                valueText: 'Français',
                valueColor: const Color(0xFF3D5216),
                onTap: () {},
                isFirst: true,
              ),
              const SizedBox(height: 4),
              _SettingSwitchRow(
                iconBackgroundColor: AppColors.bottomNavBackground,
                iconData: Icons.dark_mode_outlined,
                title: 'Mode sombre',
                value: darkMode,
                onChanged: (val) => setState(() => darkMode = val),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  void _showPasswordResetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Changer le mot de passe',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5216),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Sécurité',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: _SettingNavigationRow(
            iconBackgroundColor: Colors.black12,
            iconData: Icons.lock_outline,
            title: 'Changer le mot de passe',
            onTap: () => _showPasswordResetBottomSheet(context),
            isFirst: true,
            isLast: true,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Common Row Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SettingSwitchRow extends StatelessWidget {
  final Color iconBackgroundColor;
  final IconData? iconData;
  final bool hideIcon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _SettingSwitchRow({
    required this.iconBackgroundColor,
    this.iconData,
    this.hideIcon = false,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? 28 : 0),
          bottom: Radius.circular(isLast ? 28 : 0),
        ),
      ),
      child: Row(
        children: [
          if (!hideIcon) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white, // thumb color when active
            activeTrackColor: const Color(0xFF3D5216), // active track color
            inactiveThumbColor: Colors.white, // thumb color when inactive
            inactiveTrackColor: Colors.black26, // inactive track color
          ),
        ],
      ),
    );
  }
}

class _SettingNavigationRow extends StatelessWidget {
  final Color iconBackgroundColor;
  final IconData iconData;
  final String title;
  final String? valueText;
  final Color? valueColor;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _SettingNavigationRow({
    required this.iconBackgroundColor,
    required this.iconData,
    required this.title,
    this.valueText,
    this.valueColor,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isFirst ? 28 : 0),
            bottom: Radius.circular(isLast ? 28 : 0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (valueText != null) ...[
              Text(
                valueText!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              valueText == null
                  ? Icons.arrow_forward
                  : Icons.keyboard_arrow_down,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
