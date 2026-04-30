import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import '../services/post_service.dart';
import '../services/music_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();
  final MusicService _musicService = MusicService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  File? _selectedImage;
  String _authorName = 'Chargement...';
  String _profileImageUrl = '';
  String _userRole = 'parent';
  List<String> _selectedUserIds = [];
  List<String> _selectedUserNames = [];
  List<Map<String, dynamic>> _availableUsers = [];

  // Music properties
  MusicTrack? _selectedMusic;
  bool _isSearchingMusic = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 CreatePostPage.initState() - Démarrage du chargement');
    _loadUserData();
    _loadAvailableUsers();
  }

  Future<void> _loadUserData() async {
    debugPrint('📥 Appel de _loadUserData()');
    try {
      final data = await _postService.getCurrentUserData();
      debugPrint('📦 Données reçues: $data');

      if (mounted) {
        setState(() {
          if (data != null) {
            _userRole = (data['role'] ?? 'parent').toString();
            final firstName = (data['firstName'] ?? '').toString().trim();
            final lastName = (data['lastName'] ?? '').toString().trim();
            _authorName = '$firstName $lastName'.trim();

            if (_authorName.isEmpty) {
              _authorName = 'Utilisateur';
            }
            _profileImageUrl = (data['profileImageUrl'] ?? '')
                .toString()
                .trim();
            debugPrint('✅ Nom chargé: $_authorName');
            debugPrint('✅ Photo: $_profileImageUrl');
          } else {
            _authorName = 'Utilisateur';
            _profileImageUrl = '';
            debugPrint('⚠️ Données nulles');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _authorName = 'Utilisateur';
          _profileImageUrl = '';
          debugPrint('❌ Erreur: $e');
        });
      }
    }
  }

  Future<void> _loadAvailableUsers() async {
    final users = await _postService.getUsersForNursery();
    if (mounted) {
      setState(() {
        _availableUsers = users;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showSelectUsersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Tagguer des personnes'),
              content: SizedBox(
                width: double.maxFinite,
                child: _availableUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun utilisateur disponible dans votre établissement',
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableUsers.length,
                        itemBuilder: (context, index) {
                          final user = _availableUsers[index];
                          final isSelected = _selectedUserIds.contains(
                            user['userId'],
                          );

                          return CheckboxListTile(
                            title: Text(
                              '${user['firstName']} ${user['lastName']}',
                            ),
                            subtitle: Text(user['role']),
                            value: isSelected,
                            onChanged: (bool? value) {
                              final userName =
                                  '${user['firstName']} ${user['lastName']}';
                              setDialogState(() {
                                if (value == true) {
                                  _selectedUserIds.add(user['userId']);
                                  _selectedUserNames.add(userName);
                                } else {
                                  final index = _selectedUserIds.indexOf(
                                    user['userId'],
                                  );
                                  if (index != -1) {
                                    _selectedUserIds.removeAt(index);
                                    _selectedUserNames.removeAt(index);
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _publishPost() async {
    if (_userRole == 'parent') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les parents ne peuvent pas publier.')),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter du texte ou une image.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> mediaUrls = [];
      if (_selectedImage != null) {
        final url = await _postService.uploadImage(_selectedImage!);
        if (url != null) {
          mediaUrls.add(url);
        } else {
          throw Exception("Échec du téléchargement de l'image.");
        }
      }

      await _postService.createPost(
        content: content,
        mediaUrls: mediaUrls,
        taggedUserIds: _selectedUserIds,
        taggedUserNames: _selectedUserNames,
        musicUrl: _selectedMusic?.previewUrl,
        musicTitle: _selectedMusic?.title,
        musicArtist: _selectedMusic?.artist,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication envoyée avec succès!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildTextInputArea(),
              if (_selectedImage != null) const SizedBox(height: 20),
              if (_selectedImage != null) _buildImagePreview(),
              if (_selectedMusic != null) const SizedBox(height: 20),
              if (_selectedMusic != null) _buildMusicPreview(),
              const SizedBox(height: 20),
              _buildActionGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          const Text(
            'Create New Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: (_isLoading || _userRole == 'parent') ? null : _publishPost,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: (_isLoading || _userRole == 'parent')
                    ? Colors.grey
                    : AppColors.primaryButton,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: AppColors.primaryButton,
              shape: BoxShape.circle,
            ),
            child: _profileImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22.5),
                    child: Image.network(
                      _profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person, color: Colors.white),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(child: Icon(Icons.person, color: Colors.white)),
          ),
          const SizedBox(width: 15),
          Text(
            _authorName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Quoi de nouveau ?',
          hintStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black26,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              image: FileImage(_selectedImage!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 1.1,
        children: [
          _buildActionCard(
            icon: Icons.camera_alt_outlined,
            label: 'Photo/Video',
            onTap: _pickImage,
          ),
          _buildActionCard(
            icon: Icons.people_outline,
            label: 'tag people',
            onTap: _showSelectUsersDialog,
          ),
          _buildActionCard(
            icon: Icons.music_note_outlined,
            label: 'Musique',
            onTap: _showMusicDialog,
          ),
          _buildActionCard(
            icon: Icons.sentiment_satisfied_outlined,
            label: 'Feelings/activité',
          ),
          _buildActionCard(icon: Icons.location_on_outlined, label: 'Check in'),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMusicDialog() async {
    final TextEditingController searchController = TextEditingController();
    List<MusicTrack> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter une musique'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une musique...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      setDialogState(() {
                        _isSearchingMusic = true;
                      });
                      searchResults = await _musicService.searchMusic(value);
                      setDialogState(() {
                        _isSearchingMusic = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (_isSearchingMusic)
                  const CircularProgressIndicator()
                else if (searchResults.isEmpty && searchController.text.isEmpty)
                  FutureBuilder<List<MusicTrack>>(
                    future: _musicService.getPopularTracks(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          height: 300,
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final track = snapshot.data![index];
                              return ListTile(
                                title: Text(track.title),
                                subtitle: Text(track.artist),
                                onTap: () {
                                  setState(() {
                                    _selectedMusic = track;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  )
                else if (searchResults.isNotEmpty)
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final track = searchResults[index];
                        return ListTile(
                          leading: track.imageUrl != null
                              ? Image.network(
                                  track.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.music_note),
                          title: Text(track.title),
                          subtitle: Text(track.artist),
                          onTap: () {
                            setState(() {
                              _selectedMusic = track;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPreview() {
    if (_selectedMusic == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          if (_selectedMusic!.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _selectedMusic!.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note, size: 60),
              ),
            )
          else
            const Icon(Icons.music_note, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMusic!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedMusic!.artist,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedMusic = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
