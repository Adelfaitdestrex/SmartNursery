import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
=======
import 'package:smartnursery/features/news-feed/widgets/bottom_navbar.dart';
import 'package:smartnursery/features/news-feed/widgets/feed_header.dart';
>>>>>>> main
import 'package:smartnursery/features/news-feed/widgets/feed_post_card.dart';
import 'package:smartnursery/features/news-feed/widgets/new_post_container.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      bottomNavigationBar: const SafeArea(top: false, child: SharedBottomNavbar()),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SharedHeader(),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: const [
                    NewPostContainer(),
                    SizedBox(height: 40),
                    FeedPostCard(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
=======
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
>>>>>>> main
          ),
        ),
      ),
    );
  }
}
