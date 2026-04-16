import 'package:flutter/material.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/widgets/feed_post_card.dart';
import 'package:smartnursery/features/news-feed/widgets/new_post_container.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On garde ta barre de navigation
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
                  // CORRECTION : Suppression du 'const' ici car les widgets enfants sont dynamiques
                  children: [
                    const NewPostContainer(),
                    const SizedBox(height: 40),
                    const FeedPostCard(), // Ton post style Instagram
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}