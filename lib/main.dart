import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import 'package:smartnursery/features/admin/screens/admin_add_child_screen.dart';
import 'package:smartnursery/features/admin/screens/admin_add_user_screen.dart';
import 'package:smartnursery/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smartnursery/features/admin/screens/admin_redirection_screen.dart';
import 'package:smartnursery/features/admin/screens/admin_users_screen.dart';
import 'package:smartnursery/services/firebase/firebase_options.dart';
import 'package:smartnursery/features/admin/screens/admin_settings_screen.dart';
import 'package:smartnursery/features/classes/screens/classes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const AdminScreen(),
    );
  }
}
