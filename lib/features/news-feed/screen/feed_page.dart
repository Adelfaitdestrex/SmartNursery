import 'package:flutter/material.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/widgets/feed_post_card.dart';
import 'package:smartnursery/features/news-feed/widgets/new_post_container.dart';
import 'package:smartnursery/features/news-feed/services/post_service.dart';
import 'package:smartnursery/features/news-feed/models/post.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PostService _postService = PostService();

  /// Formatte la date relative (ex: "il y a 2h")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays}j';
    } else {
      return 'il y a ${(difference.inDays / 7).floor()}w';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SharedHeader(title: 'Flux'),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    const NewPostContainer(),
                    const SizedBox(height: 40),
                    // StreamBuilder pour afficher les posts en temps réel
                    StreamBuilder<List<Post>>(
                      stream: _postService.getPostsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur: ${snapshot.error}'),
                          );
                        }

                        final posts = snapshot.data ?? [];

                        if (posts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Aucune publication pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...posts.map((post) {
                              return Column(
                                children: [
                                  FeedPostCard(
                                    postId: post.postId,
                                    authorId: post.authorId,
                                    authorName: post.authorName,
                                    authorProfileImageUrl:
                                        post.authorProfileImageUrl,
                                    timeAgo: _formatTimeAgo(post.createdAt),
                                    content: post.content,
                                    imageUrls: post.mediaUrls,
                                    taggedUserNames: post.taggedUserNames,
                                    musicUrl: post.musicUrl,
                                    musicTitle: post.musicTitle,
                                    musicArtist: post.musicArtist,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
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
