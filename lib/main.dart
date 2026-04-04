import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/app_theme.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';

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
      home: const FeedPage(),
    );
  }
}
