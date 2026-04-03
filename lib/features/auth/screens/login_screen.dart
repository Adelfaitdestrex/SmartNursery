import 'package:flutter/material.dart';
import 'package:smartnursery/features/auth/screens/otp_verification_screen.dart';
import 'package:smartnursery/features/auth/screens/reset_password_screen.dart';

/// Thin wrapper that lets you switch between both auth screens for preview.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResetPasswordScreen();
  }
}
