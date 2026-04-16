import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import 'package:smartnursery/features/auth/screens/login_screen.dart';
import 'package:smartnursery/features/activities/screens/activities_page.dart';
import 'package:smartnursery/features/auth/screens/restricted_access.dart';
import 'package:smartnursery/features/auth/screens/role_selection.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/services/firebase/firebase_options.dart';
import 'package:smartnursery/features/classes/screens/calendier_abscence.dart';
import 'package:smartnursery/features/classes/screens/time_selection.dart';
import 'package:smartnursery/features/auth/screens/splashScreen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartnursery/features/classes/screens/instance_classe.dart' ;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. AJOUT: Initialisation du français AVANT de lancer l'application
  await initializeDateFormatting('fr', null);

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
      home: const  SmartNurseryWelcomePage()
      ,
    );
  }
}