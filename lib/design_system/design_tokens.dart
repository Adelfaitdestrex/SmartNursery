import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color pageBackground = Color(0xFFE5F8E5);
  // Header wave gradients from Figma
  static const Color headerTop = Color(0xFF89B832);
  static const Color headerBottom = Color(0xFF3D5216);
  
  static const Color cardBackground = Colors.white;
  static const Color mutedText = Color(0xFF888888);
  static const Color bottomNavBackground = Color(0xFFA2D642);
  static const Color bottomNavBorder = Color(0xFF817F7F);
  static const Color activeNavText = Colors.black;
  static const Color cantineFilterBg = Color(0xFFDFEFCA); // Light green for filter row
  static const Color cantineChipBg = Color(0xFF639D25); // Darker green for chips
  
  // Activities Colors
  static const Color activityCardRed = Color(0xFFFF6B6B);
  static const Color activityCardYellow = Color(0xFFFACC15);
  static const Color activityCardTeal = Color(0xFF48C9B0);
  static const Color activityCardAddBg = Color(0xFFE5F5E0); // Light green background for add button
  
  // Auth flow colors
  static const Color authPageBackground = Colors.white;
  static const Color primaryButton = Color(0xFF89B832);
  static const Color titleText = Color(0xFF000000);
  static const Color borderInactive = Color(0xFFCCCCCC);
  static const Color formPrefixOrange = Color(0xFFE8824A);
  static const Color formPrefixYellow = Color(0xFFF9A826);
  static const Color textLink = Color(0xFF89B832);
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

  // Button shadow targeting the figma aesthetics
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];
}

abstract final class AppTextStyles {
  static const TextStyle headerTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
  
  static const TextStyle authTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.titleText,
    fontFamily: 'Inter', // Assuming standard modern font
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
    height: 1.5,
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
