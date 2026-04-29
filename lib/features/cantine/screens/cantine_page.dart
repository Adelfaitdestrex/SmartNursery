import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/features/cantine/screens/add_meal_page.dart';
import 'package:smartnursery/features/A_propos_enfant/services/child_service.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';

class CantinePage extends StatefulWidget {
  const CantinePage({super.key});

  @override
  State<CantinePage> createState() => _CantinePageState();
}

class _CantinePageState extends State<CantinePage> {
  final List<String> filters = [
    'Tout',
    'vegetarien',
    'viande',
    'poisson',
    'salade',
  ];
  int selectedFilterIndex = 0;

  String _userRole = '';
  String _userId = '';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _fetchUserRole();
  }

  List<DateTime> _getDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(14, (index) => today.add(Duration(days: index)));
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Auj.';
    if (diff == 1) return 'Demain';
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[d.weekday - 1];
  }
  
  Widget _buildDateChip(String label, String dateNumber, DateTime date) {
    final bool isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006F1D) : const Color(0xFFECF6ED),
          borderRadius: BorderRadius.circular(32),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFFEAFFE2) : const Color(0xFF546259),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateNumber,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFEAFFE2) : const Color(0xFF546259),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = (doc.data()?['role'] ?? '').toString().toLowerCase();
        });
      }
    }
  }

  Future<void> _deleteMeal(String mealId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce repas'),
        content: const Text('Voulez-vous vraiment supprimer ce repas ?'),
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

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('meals').doc(mealId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Repas supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression : $e')),
          );
        }
      }
    }
  }

  void _showChildSelectionDialog(String mealId, String mealName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisir l\'enfant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Pour qui souhaitez-vous réserver "$mealName" ?'),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<ChildModel>>(
                  stream: ChildService().getChildrenByParentStream(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }
                    final childrenList = snapshot.data ?? [];
                    if (childrenList.isEmpty) {
                      return const Center(child: Text('Aucun enfant trouvé.'));
                    }
                    return ListView.builder(
                      itemCount: childrenList.length,
                      itemBuilder: (context, index) {
                        final child = childrenList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: child.photoGallery.isNotEmpty
                                ? NetworkImage(child.photoGallery.first)
                                : null,
                            child: child.photoGallery.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text('${child.firstName} ${child.lastName}'),
                          trailing: const Icon(Icons.add_circle, color: Color(0xFF156C4C)),
                          onTap: () {
                            Navigator.pop(context);
                            _saveMealForChild(child.childId, mealId, mealName);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMealForChild(
    String childId,
    String mealId,
    String mealName,
  ) async {
    try {
      final today = DateTime.now();
      final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Enregistrer le choix de repas pour aujourd'hui (ou une autre date si spécifiée)
      await FirebaseFirestore.instance
          .collection('enfants')
          .doc(childId)
          .collection('meal_requests')
          .doc('${dateStr}_$mealId')
          .set({
        'mealId': mealId,
        'mealName': mealName,
        'date': dateStr,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Repas "$mealName" sélectionné avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(currentIndex: 1),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Cantine',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                // Navigate back to FeedPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Ajouter menu button - Masqué pour les parents
            if (_userRole != 'parent')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _NewMenuContainer(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddMealPage()),
                    );
                  },
                ),
              ),

            if (_userRole != 'parent') const SizedBox(height: 16),

            // Date Selector
            SizedBox(
              height: 79,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _getDates().map((date) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildDateChip(_getDayLabel(date), date.day.toString(), date),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cantineFilterBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.bottomNavBorder,
                    width: 0.5,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      filters.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilterIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cantineChipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedFilterIndex == index
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              filters[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Food Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('meals')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erreur lors du chargement des repas'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final activeFilter = filters[selectedFilterIndex]
                      .toLowerCase();

                  final filteredDocs = docs.where((doc) {
                    final mealData = doc.data();
                    
                    // Filtrage par date
                    if (mealData['date'] != null) {
                      final mealDate = (mealData['date'] as Timestamp).toDate();
                      if (mealDate.year != _selectedDate.year || 
                          mealDate.month != _selectedDate.month || 
                          mealDate.day != _selectedDate.day) {
                        return false;
                      }
                    } else {
                      // Si aucun plat n'a de date, on les cache par défaut pour éviter de tout afficher.
                      // Vous pouvez retourner true si vous voulez voir les repas sans date assignée.
                      return false; 
                    }

                    if (activeFilter == 'tout') return true;
                    final tags = (mealData['tags'] as List<dynamic>? ?? [])
                        .map((e) => e.toString().toLowerCase())
                        .toList();
                    return tags.contains(activeFilter);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text('Aucun repas disponible pour ce filtre'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final mealId = doc.id;
                      final meal = doc.data();
                      final name = (meal['name'] ?? '').toString();
                      final imageUrl = (meal['imageUrl'] ?? '').toString();
                      final tags = (meal['tags'] as List<dynamic>? ?? [])
                          .map((e) => e.toString())
                          .toList();

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Nom non renseigné' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF4F4F4),
                                        image: imageUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: imageUrl.isEmpty
                                          ? const Icon(
                                              Icons.restaurant_menu,
                                              size: 42,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (tags.isNotEmpty)
                                  SizedBox(
                                    height: 28,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tags.length,
                                      separatorBuilder: (_, separatorIndex) =>
                                          const SizedBox(width: 6),
                                      itemBuilder: (context, tagIndex) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAF5D7),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            tags[tagIndex],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4F7607),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  const SizedBox(height: 28),
                              ],
                            ),
                          ),

                          // Delete button for admins/educators
                          if (_userRole == 'admin' ||
                              _userRole == 'educateur' ||
                              _userRole == 'educator')
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteMeal(mealId),
                              ),
                            ),

                          // Heart/Add button for parents
                          if (_userRole == 'parent')
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.favorite_border, color: Colors.red),
                                onPressed: () => _showChildSelectionDialog(mealId, name),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewMenuContainer extends StatelessWidget {
  final VoidCallback onTap;

  const _NewMenuContainer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 95,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8F5), // Fond léger
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 32,
                color: Color(0xFF156C4C),
              ),
            ),
            const SizedBox(width: 35),
            const Expanded(
              child: Text(
                'Ajouter un nouveau\nmenu...',
                style: AppTextStyles.newPostText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
