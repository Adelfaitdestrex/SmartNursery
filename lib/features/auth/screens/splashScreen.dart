import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartnursery/features/auth/screens/login_screen.dart';

class SmartNurseryWelcomePage extends StatefulWidget {
  const SmartNurseryWelcomePage({super.key});

  @override
  State<SmartNurseryWelcomePage> createState() =>
      _SmartNurseryWelcomePageState();
}

class _SmartNurseryWelcomePageState extends State<SmartNurseryWelcomePage> {
  @override
  void initState() {
    super.initState();
    // Redirection automatique vers le Login Screen après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(autoRedirect: false),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/entry_page.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}