import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/settings/screens/settings_page.dart';
import 'package:smartnursery/features/notifiacation/notification_screen.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 157,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.headerTop, AppColors.headerBottom],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 35, 22, 14),
      child: Row(
        children: [
          SizedBox(
            width: 61,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 61,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Notif',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              'Flux',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
        ],
      ),
    );
  }
}
