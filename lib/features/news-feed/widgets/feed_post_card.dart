import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/news-feed/services/post_service.dart';
import 'package:smartnursery/features/news-feed/widgets/music_player_widget.dart';

class FeedPostCard extends StatefulWidget {
  final String postId;
  final String authorId;
  final String authorName;
  final String authorProfileImageUrl;
  final String timeAgo;
  final String content;
  final List<String> imageUrls;
  final List<String> taggedUserNames;
  final String? musicUrl;
  final String? musicTitle;
  final String? musicArtist;

  const FeedPostCard({
    super.key,
    required this.postId,
    required this.authorId,
    this.authorName = "Mme Dupond",
    this.authorProfileImageUrl = "",
    this.timeAgo = "il y a 2h",
    this.content = "",
    this.imageUrls = const [],
    this.taggedUserNames = const [],
    this.musicUrl,
    this.musicTitle,
    this.musicArtist,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  int _currentImageIndex = 0;
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isLoadingLike = false;
  bool _isAdminOrDirectorUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserLiked();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final isAdmin = await _isAdminOrDirector();
    if (mounted) {
      setState(() {
        _isAdminOrDirectorUser = isAdmin;
      });
    }
  }

  Future<void> _checkIfUserLiked() async {
    final liked = await _postService.hasUserLiked(widget.postId);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  /// Récupère le rôle de l'utilisateur actuel depuis Firestore
  Future<String> _getCurrentUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data()?['role'] ?? '';
    } catch (e) {
      debugPrint('❌ Erreur récupération rôle: $e');
      return '';
    }
  }

  /// Vérifie si l'utilisateur actuel est admin ou director
  Future<bool> _isAdminOrDirector() async {
    final role = await _getCurrentUserRole();
    return role == 'admin' || role == 'director';
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLoadingLike = true;
    });

    try {
      await _postService.toggleLike(widget.postId);
      // L'état se met à jour via le StreamBuilder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      setState(() {
        _isLoadingLike = false;
      });
    }
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire un commentaire')),
      );
      return;
    }

    try {
      await _postService.addComment(widget.postId, commentText);
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Commentaire ajouté !')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le post ?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce post ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _postService.deletePost(widget.postId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post supprimé')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Commentaires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Comments list
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _postService.getCommentsStream(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      final comments = snapshot.data ?? [];

                      if (comments.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucun commentaire pour le moment',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final createdAt = comment['createdAt'] != null
                              ? (comment['createdAt'] as dynamic).toDate()
                              : DateTime.now();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.headerTop,
                                      backgroundImage:
                                          (comment['authorProfileImageUrl'] ??
                                                  '')
                                              .isNotEmpty
                                          ? NetworkImage(
                                              comment['authorProfileImageUrl']
                                                  as String,
                                            )
                                          : null,
                                      child:
                                          (comment['authorProfileImageUrl'] ??
                                                  '')
                                              .isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['authorName'] ??
                                                'Utilisateur',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _formatTimeAgo(createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment['content'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                // Comment input
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    top: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Ajouter un commentaire...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _addComment,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryButton,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays}j';
    } else {
      return 'il y a ${(difference.inDays / 7).floor()}w';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.feedCard,
      ),
      child: Column(
        children: [
          // --- HEADER DU POST ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.5,
                  backgroundColor: AppColors.headerTop,
                  backgroundImage: widget.authorProfileImageUrl.isNotEmpty
                      ? NetworkImage(widget.authorProfileImageUrl)
                      : null,
                  child: widget.authorProfileImageUrl.isEmpty
                      ? const Text(
                          '+',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Utilisation de la variable authorName
                    Text(
                      widget.authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Utilisation de la variable timeAgo
                    Text(
                      widget.timeAgo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, size: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePost();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    // ✅ Admin ou auteur peuvent supprimer
                    final isAuthor = currentUser?.uid == widget.authorId;

                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'save',
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border, size: 20),
                            SizedBox(width: 8),
                            Text('Enregistrer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'hide',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_off_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Masquer'),
                          ],
                        ),
                      ),
                      if (isAuthor)
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      // ✅ Bouton supprimer pour les admins
                      if (_isAdminOrDirectorUser && !isAuthor)
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Supprimer (Admin)',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(
                              Icons.report_outlined,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Signaler',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          // --- ZONE D'IMAGES ---
          if (widget.imageUrls.isNotEmpty)
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // Utilisation de Image.network car les liens viendront d'internet (Firebase)
                      return Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.cover,
                        // Petit bonus : affiche un indicateur de chargement le temps que l'image arrive
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),

                  // --- COMPTEUR D'IMAGES ---
                  if (widget.imageUrls.length > 1)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // --- LES PETITS POINTS EN BAS ---
                  if (widget.imageUrls.length > 1)
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.imageUrls.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // --- CONTENU DU POST ---
          if (widget.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                widget.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // --- MUSIQUE ---
          if (widget.musicUrl != null &&
              widget.musicUrl!.isNotEmpty &&
              widget.musicTitle != null &&
              widget.musicArtist != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: MusicPlayerWidget(
                musicUrl: widget.musicUrl!,
                musicTitle: widget.musicTitle!,
                musicArtist: widget.musicArtist!,
                durationSeconds: 30,
              ),
            ),

          // --- UTILISATEURS TAGGÉS ---
          if (widget.taggedUserNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                'Taggés: ${widget.taggedUserNames.join(', ')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // --- INTERACTIONS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                // Résumé dynamique des réactions et commentaires
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Likes count
                    StreamBuilder<int>(
                      stream: _postService.getLikesCountStream(widget.postId),
                      builder: (context, snapshot) {
                        final likesCount = snapshot.data ?? 0;
                        return Row(
                          children: [
                            if (likesCount > 0) ...[
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.thumb_up,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(-6, 0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(
                                      BorderSide(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              likesCount > 0
                                  ? '$likesCount'
                                  : 'Soyez le premier à réagir',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (likesCount > 0)
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _postService.getLikesWithUserInfo(
                                  widget.postId,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const SizedBox();
                                  }

                                  final likes = snapshot.data!;
                                  return Tooltip(
                                    message: likes
                                        .map((l) => l['name'])
                                        .join(', '),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                        children: likes.take(3).map((like) {
                                          return Transform.translate(
                                            offset: Offset(
                                              -8.0 *
                                                  (likes.indexOf(
                                                    like,
                                                  )).toDouble(),
                                              0,
                                            ),
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage:
                                                  (like['profileImageUrl'] ??
                                                          '')
                                                      .isNotEmpty
                                                  ? NetworkImage(
                                                      like['profileImageUrl']
                                                          as String,
                                                    )
                                                  : null,
                                              child:
                                                  (like['profileImageUrl'] ??
                                                          '')
                                                      .isEmpty
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 8,
                                                    )
                                                  : null,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    // Comments count
                    StreamBuilder<int>(
                      stream: _postService.getCommentsCountStream(
                        widget.postId,
                      ),
                      builder: (context, snapshot) {
                        final commentsCount = snapshot.data ?? 0;
                        return Text(
                          '$commentsCount commentaire${commentsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        _isLiked
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        'J\'aime',
                        _isLoadingLike ? null : _toggleLike,
                        isActive: _isLiked,
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        Icons.chat_bubble_outline,
                        'Commenter',
                        _showCommentsBottomSheet,
                      ),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        Icons.share_outlined,
                        'Partager',
                        () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue : Colors.grey[700],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
