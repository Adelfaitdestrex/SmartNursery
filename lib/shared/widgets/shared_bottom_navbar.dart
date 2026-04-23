import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/features/cantine/screens/cantine_page.dart';
import 'package:smartnursery/features/messages/screens/messages_page.dart';
import 'package:smartnursery/features/activities/screens/activities_page.dart';
import 'package:smartnursery/features/classes/screens/classes_page.dart';

class SharedBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const SharedBottomNavbar({super.key, this.currentIndex = 0});

  static const String _iconFlux = 'assets/icons/Icon.png';
  static const String _iconCantine = 'assets/icons/cafeteria.png';
  static const String _iconMessage = 'assets/icons/email.png';
  static const String _iconActivite = 'assets/icons/crayon.png';
  static const String _iconClasse = 'assets/icons/sac-decole.png';

  void _onNavigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    Widget page;
    switch (index) {
      case 0:
        page = const FeedPage();
        break;
      case 1:
        page = const CantinePage();
        break;
      case 2:
        page = const MessagesPage();
        break;
      case 3:
        page = const ActivitiesPage();
        break;
      case 4:
        page = const ClassesPage();
        break;
      // Add other cases later
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Slightly reduced to fit better when glued to bottom
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        border: Border(top: BorderSide(color: AppColors.bottomNavBorder)), // Only top border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            _NavItem(
              label: 'Flux', 
              iconPath: _iconFlux, 
              active: currentIndex == 0,
              onTap: () => _onNavigate(context, 0),
            ),
            _NavItem(
              label: 'Cantine', 
              iconPath: _iconCantine, 
              active: currentIndex == 1,
              onTap: () => _onNavigate(context, 1),
            ),
            _NavItem(
              label: 'Message', 
              iconPath: _iconMessage, 
              active: currentIndex == 2,
              onTap: () => _onNavigate(context, 2),
            ),
            _NavItem(
              label: 'Activité', 
              iconPath: _iconActivite, 
              active: currentIndex == 3,
              onTap: () => _onNavigate(context, 3),
            ),
            _NavItem(
              label: 'Classe', 
              iconPath: _iconClasse, 
              active: currentIndex == 4,
              onTap: () => _onNavigate(context, 4),
            ),
          ],
        ),
      );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.label,
    required this.iconPath,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 35,
              height: 35,
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white), // Fallback if asset is missing
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: active ? AppColors.activeNavText : Colors.white,
                fontSize: 16, // Augmentation de la taille de 6
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
