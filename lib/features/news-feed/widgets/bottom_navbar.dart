import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  static const String _iconFlux =
      'https://www.figma.com/api/mcp/asset/2ef14b88-c394-46db-8755-b325923f6a1e';
  static const String _iconCantine =
      'https://www.figma.com/api/mcp/asset/38101949-612f-47d2-a53d-0c4f56cafe33';
  static const String _iconMessage =
      'https://www.figma.com/api/mcp/asset/60cda790-5ded-4a00-bcdb-5945158a47e2';
  static const String _iconActivite =
      'https://www.figma.com/api/mcp/asset/2d61f4f6-3681-473a-b3a3-27e4bbed1826';
  static const String _iconClasse =
      'https://www.figma.com/api/mcp/asset/8ce3a5a8-bf73-40d6-b78b-2f89e6ab87db';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: AppColors.bottomNavBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _NavItem(label: 'Flux', iconUrl: _iconFlux, active: true),
            _NavItem(label: 'Cantine', iconUrl: _iconCantine),
            _NavItem(label: 'Message', iconUrl: _iconMessage),
            _NavItem(label: 'Activité', iconUrl: _iconActivite),
            _NavItem(label: 'Classe', iconUrl: _iconClasse),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconUrl;
  final bool active;

  const _NavItem({
    required this.label,
    required this.iconUrl,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Image.network(iconUrl, fit: BoxFit.contain),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.navLabel.copyWith(
              color: active ? AppColors.activeNavText : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
