import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/settings/screens/settings_page.dart'; // adapte le chemin

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
                  'Setting',
                  style: TextStyle(color: Colors.white, fontSize: 29 / 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 23),
          const Expanded(
            child: Text(
              'Flux d\'actualité',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
