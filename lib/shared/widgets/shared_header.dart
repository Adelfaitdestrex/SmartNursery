import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/settings/screens/settings_page.dart';
import 'package:smartnursery/features/notifiacation/notification_screen.dart';

class SharedHeader extends StatelessWidget {
  final String title;
  final Widget? leftWidget;
  final String? leftLabel;
  final VoidCallback? onLeftTap;
  final IconData rightIcon;
  final VoidCallback? onRightTap;

  /// Widget personnalisé à afficher à droite (remplace l'icône rightIcon si fourni)
  final Widget? rightWidget;

  const SharedHeader({
    super.key,
    this.title = 'Flux d\'actualité',
    this.leftWidget,
    this.leftLabel = 'Setting',
    this.onLeftTap,
    this.rightIcon = Icons.notifications_none,
    this.onRightTap,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.headerTop, AppColors.headerBottom],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onLeftTap ??
                      () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const SettingsPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    child: leftWidget ??
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 32, height: 2, color: Colors.white),
                            const SizedBox(height: 7),
                            Container(width: 32, height: 2, color: Colors.white),
                            const SizedBox(height: 7),
                            Container(width: 32, height: 2, color: Colors.white),
                          ],
                        ),
                  ),
                ),
                if (leftLabel != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    leftLabel!,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 29 / 2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 23),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          SizedBox(
            width: 84,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onRightTap ??
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ),
                behavior: HitTestBehavior.opaque,
                child: rightWidget ??
                    Icon(rightIcon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
