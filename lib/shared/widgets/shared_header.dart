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

  const SharedHeader({
    super.key,
    this.title = 'Flux d\'actualité',
    this.leftWidget,
    this.leftLabel = 'Setting',
    this.onLeftTap,
    this.rightIcon = Icons.notifications_none,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  onTap: onLeftTap ??
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          ),
                  behavior: HitTestBehavior.opaque,
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
                if (leftLabel != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    leftLabel!,
                    style: const TextStyle(color: Colors.white, fontSize: 29 / 2),
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
                child: Icon(rightIcon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
