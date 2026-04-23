import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import 'package:smartnursery/features/A_propos_enfant/details_des_activit%C3%A9es.dart';
import 'package:smartnursery/services/firebase/firebase_options.dart';
import 'package:smartnursery/features/auth/screens/splashScreen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartnursery/features/A_propos_enfant/journal.dart';
import 'package:smartnursery/features/classes/screens/incident_page.dart';
import 'package:smartnursery/services/theme_provider.dart';
import 'package:smartnursery/features/reconnaissancefaciale/recherche.dart';
import 'package:smartnursery/features/reconnaissancefaciale/reconnaissance_faciale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. AJOUT: Initialisation du français AVANT de lancer l'application
  await initializeDateFormatting('fr', null);

  runApp(const SmartNurseryApp());
}

class SmartNurseryApp extends StatefulWidget {
  const SmartNurseryApp({super.key});

  @override
  State<SmartNurseryApp> createState() => _SmartNurseryAppState();
}

class _SmartNurseryAppState extends State<SmartNurseryApp> {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _themeNotifier,
      child: _SmartNurseryAppContent(themeNotifier: _themeNotifier),
    );
  }
}

class _SmartNurseryAppContent extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const _SmartNurseryAppContent({required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmartNursery',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeNotifier.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SmartNurseryWelcomePage(),
        );
      },
    );
  }
}
