import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.pageBackground,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.headerTop),
      useMaterial3: true,
    );
  }
}
