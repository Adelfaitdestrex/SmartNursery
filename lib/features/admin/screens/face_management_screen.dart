import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Écran de gestion des visages pour la reconnaissance faciale.
/// Accessible depuis l'admin → liste des utilisateurs.
/// Permet d'associer une ou plusieurs photos à un utilisateur existant.
class FaceManagementScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userRole;

  const FaceManagementScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userRole,
  });

  @override
  State<FaceManagementScreen> createState() => _FaceManagementScreenState();
}

class _FaceManagementScreenState extends State<FaceManagementScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<Map<String, String>> _facePhotos = []; // {name, url}
  bool _loadingPhotos = true;
  bool? _hasFaceData;

  static const Color _green = Color(0xFF006F1D);
  static const Color _greenLight = Color(0xFFECF6ED);
  static const Color _greenAccent = Color(0xFF88C043);

  @override
  void initState() {
    super.initState();
    _loadFaceData();
  }

  // ── Charge les photos existantes depuis Storage + flag Firestore ──────────
  Future<void> _loadFaceData() async {
    setState(() => _loadingPhotos = true);
    try {
      // Firestore flag
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      _hasFaceData = doc.data()?['hasFaceData'] as bool? ?? false;

      // Storage photos
      final listResult = await FirebaseStorage.instance
          .ref('faces/parents/${widget.userId}')
          .listAll();

      final photos = <Map<String, String>>[];
      for (final item in listResult.items) {
        try {
          final url = await item.getDownloadURL();
          photos.add({'name': item.name, 'url': url});
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _facePhotos = photos;
          _loadingPhotos = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPhotos = false);
    }
  }

  // ── Upload une nouvelle photo ─────────────────────────────────────────────
  Future<void> _addPhoto(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'faces/parents/${widget.userId}/$timestamp.jpg';
      final ref = FirebaseStorage.instance.ref(path);
      await ref.putFile(File(picked.path));

      // Marquer hasFaceData = true dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
            'hasFaceData': true,
            'lastFaceRegisteredAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      _showSnack('✅ Visage ajouté avec succès !', success: true);
      await _loadFaceData();
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Erreur : $e', success: false);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Supprime une photo ───────────────────────────────────────────────────
  Future<void> _deletePhoto(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ce visage ?'),
        content: const Text(
          'Cette photo sera retirée de la base de reconnaissance faciale.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseStorage.instance
          .ref('faces/parents/${widget.userId}/$name')
          .delete();

      // Si plus aucun visage → mettre hasFaceData = false
      final remaining = _facePhotos.where((p) => p['name'] != name).toList();
      if (remaining.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set({'hasFaceData': false}, SetOptions(merge: true));
      }

      if (!mounted) return;
      _showSnack('Photo supprimée', success: true);
      await _loadFaceData();
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Impossible de supprimer : $e', success: false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? _green : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter une photo de visage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28352E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pour ${widget.userName}',
                style: const TextStyle(color: Color(0xFF546259), fontSize: 14),
              ),
              const SizedBox(height: 24),
              _OptionTile(
                icon: Icons.photo_camera,
                label: 'Prendre une photo',
                subtitle: 'Ouvrir la caméra',
                color: _green,
                onTap: () {
                  Navigator.pop(context);
                  _addPhoto(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.photo_library,
                label: 'Choisir depuis la galerie',
                subtitle: 'Sélectionner une photo existante',
                color: _greenAccent,
                onTap: () {
                  Navigator.pop(context);
                  _addPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildHeader(),

            // ── Contenu ─────────────────────────────────────────────────────
            Expanded(
              child: _loadingPhotos
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Carte identité utilisateur
                          _buildUserCard(),
                          const SizedBox(height: 24),

                          // Statut Firestore
                          _buildFirestoreStatus(),
                          const SizedBox(height: 24),

                          // Section photos
                          _buildPhotosSection(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // FAB Ajouter
      floatingActionButton: _isUploading
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: _greenAccent,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _showAddOptions,
              backgroundColor: _green,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text(
                'Ajouter un visage',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD6E6DB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _green),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestion des Visages',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _green,
                  ),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF546259),
                  ),
                ),
              ],
            ),
          ),
          // Badge nombre de photos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_facePhotos.length} photo${_facePhotos.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final roleLabel = _getRoleLabel(widget.userRole);
    final roleColor = _getRoleColor(widget.userRole);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _greenLight,
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28352E),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.face_retouching_natural, color: _greenAccent, size: 28),
        ],
      ),
    );
  }

  Widget _buildFirestoreStatus() {
    final hasData = _hasFaceData ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasData
            ? const Color(0xFFECF6ED)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData ? _greenAccent : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasData ? Icons.check_circle : Icons.warning_amber_rounded,
            color: hasData ? _green : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData
                      ? 'Reconnaissance faciale activée'
                      : 'Aucun visage enregistré',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: hasData ? _green : Colors.orange[800],
                    fontSize: 14,
                  ),
                ),
                Text(
                  hasData
                      ? 'Ce profil sera reconnu lors du scan'
                      : 'Ajoutez au moins une photo pour activer la reconnaissance',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasData
                        ? const Color(0xFF546259)
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Photos enregistrées',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28352E),
              ),
            ),
            const Spacer(),
            if (_facePhotos.isNotEmpty)
              Text(
                '${_facePhotos.length}/5 max recommandé',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF546259),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Plus vous ajoutez de photos sous différents angles, meilleure sera la reconnaissance.',
          style: TextStyle(fontSize: 12, color: Color(0xFF78928A)),
        ),
        const SizedBox(height: 16),

        if (_facePhotos.isEmpty)
          _buildEmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _facePhotos.length,
            itemBuilder: (context, index) {
              return _FacePhotoCard(
                url: _facePhotos[index]['url']!,
                name: _facePhotos[index]['name']!,
                index: index + 1,
                onDelete: () => _deletePhoto(_facePhotos[index]['name']!),
              );
            },
          ),

        const SizedBox(height: 100), // espace pour le FAB
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6E6DB),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.face_retouching_off,
              size: 48,
              color: _greenAccent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune photo enregistrée',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF28352E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Appuyez sur "Ajouter un visage" pour\ncommencer l\'enregistrement',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF546259), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return 'Parent';
      case 'admin':
        return 'Administrateur';
      case 'educator':
      case 'educateur':
        return 'Éducateur';
      case 'director':
        return 'Directeur';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return const Color(0xFF1565C0);
      case 'admin':
        return const Color(0xFFB71C1C);
      case 'educator':
      case 'educateur':
        return _green;
      case 'director':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }
}

// ── Carte photo ─────────────────────────────────────────────────────────────

class _FacePhotoCard extends StatelessWidget {
  final String url;
  final String name;
  final int index;
  final VoidCallback onDelete;

  const _FacePhotoCard({
    required this.url,
    required this.name,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFECF6ED),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stack) => Container(
                color: const Color(0xFFECF6ED),
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),

            // Gradient bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Photo $index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Badge numéro
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF006F1D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Option Tile pour le BottomSheet ─────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF546259),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
