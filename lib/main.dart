import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartNursery',
      theme: AppTheme.light,
      home: const FeedPage(),
    );
  }
}
