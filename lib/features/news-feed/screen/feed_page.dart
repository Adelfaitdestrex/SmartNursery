import 'package:flutter/material.dart';
import 'package:smartnursery/features/news-feed/widgets/bottom_navbar.dart';
import 'package:smartnursery/features/news-feed/widgets/feed_header.dart';
import 'package:smartnursery/features/news-feed/widgets/feed_post_card.dart';
import 'package:smartnursery/features/news-feed/widgets/new_post_container.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SafeArea(top: false, child: BottomNavbar()),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: const [
                FeedHeader(),
                SizedBox(height: 40),
                NewPostContainer(),
                SizedBox(height: 40),
                FeedPostCard(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
