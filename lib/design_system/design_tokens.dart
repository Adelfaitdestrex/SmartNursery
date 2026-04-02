import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color pageBackground = Color(0xFFE5F8E5);
  static const Color headerTop = Color(0xFF89B832);
  static const Color headerBottom = Color(0xFF3D5216);
  static const Color cardBackground = Colors.white;
  static const Color mutedText = Color(0x80000000);
  static const Color bottomNavBackground = Color(0xFFA2D642);
  static const Color bottomNavBorder = Color(0xFF817F7F);
  static const Color activeNavText = Color(0xFF39471F);
}

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> feedCard = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 8),
      blurRadius: 4,
    ),
  ];
}

abstract final class AppTextStyles {
  static const TextStyle headerTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle newPostText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
    height: 1.2,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
