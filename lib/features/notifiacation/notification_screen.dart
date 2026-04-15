import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedTab = 'Tout';
  final List<String> _tabs = ['Tout', 'Message', 'Activité'];

  // Toggle this to true to verify the empty state!
  final bool _isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SharedBottomNavbar(currentIndex: -1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: _isEmpty ? _buildEmptyState() : _buildNotificationList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.headerTop,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Bouton retour
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Notifications',
              style: AppTextStyles.headerTitle,
            ),
          ),
          // Badge notification
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.headerTop : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.headerTop
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildNotificationCard(
          name: 'Léo a fini son repas',
          description: "Léo a mangé toute sa pomme de terre, il a l'air heureux !",
          time: '10 min',
          badge: '2',
        ),
        _buildNotificationCard(
          name: 'Emma — Activité peinture',
          description: "Emma a participé à l'activité peinture de l'après-midi.",
          time: '1h',
          badge: '1',
          badgeColor: Colors.green,
        ),
        _buildNotificationCard(
          name: 'Absence signalée',
          description: "Léo Thompson est absent aujourd'hui — motif médical.",
          time: '2h',
          badge: '!',
          badgeColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String name,
    required String description,
    required String time,
    required String badge,
    Color badgeColor = Colors.blue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.headerTop.withValues(alpha: 0.15),
            child: Icon(Icons.child_care, color: AppColors.headerTop, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF546259),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF546259),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            "Pas de notifications",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tout semble calme dans la crèche",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF546259),
            ),
          ),
        ],
      ),
    );
  }
}