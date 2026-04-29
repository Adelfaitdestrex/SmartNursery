import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/classes/models/class_model.dart';
import 'package:smartnursery/features/classes/services/class_service.dart';
import 'package:smartnursery/shared/widgets/admin_profile_avatar.dart';
import 'admin_add_user_screen.dart';
import 'admin_add_child_screen.dart';
import 'admin_edit_user_screen.dart';
import 'admin_manage_classes_screen.dart';
import 'add_children_flow_page.dart';
import 'face_management_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  List<String> _tabs = ['Tous'];
  int _usersCount = 0;
  int _teachersCount = 0;
  int _parentsCount = 0;
  String _currentNurseryId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserNurseryId();
    _loadRolesFromFirebase();
    _startStatisticsRefresh();
  }

  Future<void> _loadCurrentUserNurseryId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          final nurseryId = userDoc['nurseryId'] as String?;
          if (mounted) {
            setState(() {
              _currentNurseryId = nurseryId ?? '';
            });
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement de nurseryId: $e');
    }
  }

  void _startStatisticsRefresh() {
    // Charger les statistiques immédiatement
    _loadStatistics();
    _loadRolesFromFirebase();
    // Puis les actualiser toutes les 5 secondes
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        await _loadStatistics();
      }
      return mounted;
    });
  }

  Future<void> _loadRolesFromFirebase() async {
    try {
      if (_currentNurseryId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nurseryId', isEqualTo: _currentNurseryId)
          .get();
      final roles = <String>{'Tous'};
      for (var doc in snapshot.docs) {
        final role = doc['role'] as String?;
        if (role != null && role.isNotEmpty) {
          roles.add(role);
        }
      }
      if (mounted) {
        setState(() {
          _tabs = roles.toList();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des rôles: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      if (_currentNurseryId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nurseryId', isEqualTo: _currentNurseryId)
          .get();
      int users = snapshot.docs.length;
      int teachers = snapshot.docs
          .where(
            (doc) => (doc['role'] == 'Enseignant' || doc['role'] == 'educator'),
          )
          .length;
      int parents = snapshot.docs
          .where(
            (doc) =>
                (doc['isActive'] == true &&
                (doc['role'] == 'Parent' || doc['role'] == 'parent')),
          )
          .length;

      if (mounted) {
        setState(() {
          _usersCount = users;
          _teachersCount = teachers;
          _parentsCount = parents;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground, // #F4FBF4
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        _buildSearchAndFilters(),
                        const SizedBox(height: 32),
                        _buildListHeader(),
                        const SizedBox(height: 16),
                        _buildUsersList(),
                        const SizedBox(height: 32),
                        _buildBottomStatsRow(),
                        const SizedBox(height: 32),
                        _buildClassesSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // FABs
            Positioned(
              bottom: 40,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Action Ajouter Enfant
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAddChildScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.child_care,
                            color: Color(0xFF006F1D),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Ajouter Enfant',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF006F1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main Action Ajouter Utilisateur
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAddUserScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF006F1D), Color(0xFF006118)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x2628352E), // rgba(40,53,46,0.15)
                            offset: Offset(0, 12),
                            blurRadius: 32,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
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
                    Icons.menu,
                    color: Color(0xFF006F1D),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Utilisateurs',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006F1D),
                ),
              ),
            ],
          ),
          const AdminProfileAvatar(
            size: 40,
            borderColor: Color(0xFF91F78E),
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E6DB),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0x80546259),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Rechercher un utilisateur...',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Color(0x80546259),
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
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E6DB),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFF006F1D),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
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
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Text(
              'Liste du Personnel et\nParents',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28352E),
                height: 1.2,
                letterSpacing: -0.45,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_usersCount',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xB3546259),
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
              const Text(
                'UTILISATEURS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xB3546259),
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_currentNurseryId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('nurseryId', isEqualTo: _currentNurseryId);
    if (_selectedTabIndex != 0) {
      query = query.where('role', isEqualTo: _tabs[_selectedTabIndex]);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        // Filtrer les utilisateurs par nom de recherche
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final userName = (doc['name'] as String? ?? '').toLowerCase();
          return userName.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text("Aucun utilisateur trouvé pour '$_searchQuery'"),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: filteredDocs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final userId = document.id;
              final userName = data['name'] as String? ?? 'No Name';
              final userRole = data['role'] as String? ?? 'No Role';
              final hasFaceData = data['hasFaceData'] as bool? ?? false;
              return _UserCard(
                name: userName,
                role: userRole,
                roleColor: const Color(0xFFB4FDB4),
                roleTextColor: const Color(0xFF1F632C),
                avatarUrl:
                    data['profileImageUrl'] ?? 'https://i.pravatar.cc/150',
                isActive: data['isActive'] ?? true,
                isInactiveOpacity: !(data['isActive'] ?? true),
                hasFaceData: hasFaceData,
                onDelete: () =>
                    _deleteUserWithConfirmation(context, document, userName),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminEditUserScreen(user: document),
                    ),
                  );
                },
                onManageFace: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FaceManagementScreen(
                        userId: userId,
                        userName: userName,
                        userRole: userRole,
                      ),
                    ),
                  );
                },
                onAddChild: userRole == 'Parent'
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddChildrenFlowPage(
                              parentId: userId,
                              numberOfChildren: 1,
                              nurseryId: data['nurseryId'] ?? '',
                            ),
                          ),
                        );
                      }
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBottomStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 163,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x4DA3F69C),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Color(0xFF1C6D25),
                    size: 28,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_parentsCount',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C6D25),
                          height: 1.2,
                        ),
                      ),
                      const Text(
                        'Parents connectés',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF065F18),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 163,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x4DB4FDB4),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF286C34),
                    size: 28,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_teachersCount',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF286C34),
                          height: 1.2,
                        ),
                      ),
                      const Text(
                        'Enseignants',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F632C),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSection() {
    final classService = ClassService();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminManageClassesScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButton,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ClassModel>>(
            stream: classService.getClassesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final classes = snapshot.data ?? [];

              if (classes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune classe créée',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length > 3 ? 3 : classes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final classData = classes[index];
                  final colorHex = classData.color ?? '#7DF0FC';
                  final color = Color(
                    int.parse('0xFF${colorHex.substring(1)}'),
                  );

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classData.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${classData.currentSize}/${classData.capacity} enfants',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant de supprimer un utilisateur
  Future<void> _deleteUserWithConfirmation(
    BuildContext context,
    DocumentSnapshot document,
    String userName,
  ) async {
    // Empêcher l'admin de se supprimer lui-même
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (document.id == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas supprimer votre propre compte.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le compte de $userName ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await document.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String role;
  final Color roleColor;
  final Color roleTextColor;
  final String avatarUrl;
  final bool isActive;
  final bool isInactiveOpacity;
  final bool hasFaceData;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onManageFace;
  final VoidCallback? onAddChild;

  const _UserCard({
    required this.name,
    required this.role,
    required this.roleColor,
    required this.roleTextColor,
    required this.avatarUrl,
    required this.isActive,
    this.isInactiveOpacity = false,
    this.hasFaceData = false,
    required this.onDelete,
    required this.onEdit,
    required this.onManageFace,
    this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isInactiveOpacity ? 0.8 : 1.0),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          // ── Avatar avec badge visage ───────────────────────────────────
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isInactiveOpacity
                        ? const Color(0xFFD6E6DB)
                        : const Color(0x4D91F78E),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                    colorFilter: isInactiveOpacity
                        ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                        : null,
                  ),
                ),
              ),
              // Petit badge visage en bas à droite de l'avatar
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasFaceData
                        ? const Color(0xFF006F1D)
                        : const Color(0xFFD6E6DB),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    hasFaceData ? Icons.face : Icons.face_retouching_off,
                    size: 9,
                    color: hasFaceData ? Colors.white : const Color(0xFF546259),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Infos utilisateur ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28352E),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleTextColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF006F1D)
                            : const Color(0x4D546259),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: isActive
                            ? const Color(0xFF546259)
                            : const Color(0x99546259),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Menu actions ─────────────────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF546259),
              size: 22,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'face',
                child: Row(
                  children: [
                    Icon(
                      hasFaceData
                          ? Icons.face_retouching_natural
                          : Icons.face_retouching_off,
                      size: 20,
                      color: hasFaceData
                          ? const Color(0xFF006F1D)
                          : const Color(0xFF546259),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hasFaceData ? 'Gérer les visages' : 'Ajouter un visage',
                      style: TextStyle(
                        color: hasFaceData
                            ? const Color(0xFF006F1D)
                            : const Color(0xFF28352E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAddChild != null)
                const PopupMenuItem(
                  value: 'child',
                  child: Row(
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 20,
                        color: Color(0xFF286C34),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Ajouter un enfant',
                        style: TextStyle(
                          color: Color(0xFF28352E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Color(0xFF546259),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Modifier',
                      style: TextStyle(
                        color: Color(0xFF28352E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'face':
                  onManageFace();
                case 'child':
                  onAddChild?.call();
                case 'edit':
                  onEdit();
                case 'delete':
                  onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}
