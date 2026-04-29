import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/features/activities/models/activity_model.dart';
import 'package:smartnursery/features/activities/widgets/activity_card.dart';
import 'package:smartnursery/features/activities/screens/add_activity_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late DateTime _selectedDate;
  String _selectedFilter = 'Toutes';
  String _userRole = '';
  String _nurseryId = '';
  List<ActivityModel> _activities = [];
  StreamSubscription<QuerySnapshot>? _activitiesSub;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _activitiesSub?.cancel();
    super.dispose();
  }

  void _listenToActivities() {
    if (_nurseryId.isEmpty) return;
    _activitiesSub?.cancel();
    _activitiesSub = FirebaseFirestore.instance
        .collection('activities')
        .where('nurseryId', isEqualTo: _nurseryId)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _activities = snap.docs
            .map((doc) => ActivityModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList();
        _activities.sort((a, b) => b.date.compareTo(a.date));
      });
    });
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = (doc.data()?['role'] ?? '').toString().toLowerCase();
          _nurseryId = doc.data()?['nurseryId'] as String? ?? '';
        });
        _listenToActivities();
      }
    }
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Demain';
    if (diff == -1) return 'Hier';
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[d.weekday - 1];
  }

  List<DateTime> _getActivityDates() {
    final dates = _activities
        .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
        .toSet()
        .toList();
    if (dates.isEmpty) {
      final now = DateTime.now();
      return [DateTime(now.year, now.month, now.day)];
    }
    dates.sort();
    return dates;
  }

  List<ActivityModel> get _filteredActivities {
    // Filtrer d'abord par date
    var list = _activities.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate == _selectedDate;
    }).toList();

    // Puis par statut
    if (_selectedFilter == 'En cours') {
      return list.where((a) => a.status == ActivityStatus.enCours).toList();
    } else if (_selectedFilter == 'Terminées') {
      return list.where((a) => a.status == ActivityStatus.terminee).toList();
    } else if (_selectedFilter == 'À venir') {
      return list.where((a) => a.status == ActivityStatus.aVenir).toList();
    }
    return list;
  }

  void _navigateToAddActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddActivityPage()),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final showAddActivity = _userRole == 'educateur' || _userRole == 'educator' || _userRole == 'admin' || _userRole == 'directeur';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      bottomNavigationBar: const SafeArea(top: false, child: SharedBottomNavbar(currentIndex: 3)),
      floatingActionButton: showAddActivity ? Container(
        margin: const EdgeInsets.only(bottom: 24, right: 8),
        child: FloatingActionButton(
          onPressed: _navigateToAddActivity,
          backgroundColor: const Color(0xFF006F1D),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ) : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedHeader(
              title: 'Activités',
              leftWidget: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ajouter nouvelle activité card
                    if (showAddActivity)
                      GestureDetector(
                        onTap: _navigateToAddActivity,
                        child: Container(
                          height: 113,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F8E5),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.widgets, size: 55, color: Colors.orange), // placeholder
                              SizedBox(width: 12),
                              Text(
                                'Ajouter une nouvelle activité',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0x80000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showAddActivity)
                      const SizedBox(height: 32),
                    // Date Selector
                    SizedBox(
                      height: 79,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getActivityDates().map((date) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildDateChip(_getDayLabel(date), date.day.toString(), date),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Toutes'),
                          const SizedBox(width: 12),
                          _buildFilterChip('En cours'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Terminées'),
                          const SizedBox(width: 12),
                          _buildFilterChip('À venir'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Activities List
                    if (_filteredActivities.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Aucune activité pour ce filtre.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ..._filteredActivities.map((activity) => ActivityCard(
                            activity: activity,
                            userRole: _userRole,
                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                            nurseryId: _nurseryId,
                          )),
                    const SizedBox(height: 60), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006F1D) : const Color(0xFFD6E6DB),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFEAFFE2) : const Color(0xFF546259),
          ),
        ),
      ),
    );
  }
}
