import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import './features/auth/screens/reset_password_screen.dart';

void main() {
  runApp(const SmartNurseryApp());
}

class SmartNurseryApp extends StatelessWidget {
  const SmartNurseryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartNursery',
      theme: AppTheme.light,
      home: const ResetPasswordScreen(),
    );
  }
}
