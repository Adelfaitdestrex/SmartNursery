import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
<<<<<<< HEAD
import 'package:smartnursery/features/news-feed/screen/create_post_page.dart';
=======
>>>>>>> main

class NewPostContainer extends StatelessWidget {
  const NewPostContainer({super.key});

  static const String _userImageUrl =
      'https://www.figma.com/api/mcp/asset/c019e77c-90d7-4150-980b-17d36b67c142';

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePostPage()),
        );
      },
      child: Container(
        height: 95,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Image.network(_userImageUrl, fit: BoxFit.cover),
            ),
            const SizedBox(width: 35),
            const Expanded(
              child: Text(
                'Créer une nouvelle\npublication...',
                style: AppTextStyles.newPostText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
=======
    return Container(
      height: 95,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.network(_userImageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: 35),
          const Expanded(
            child: Text(
              'Créer une nouvelle\npublication...',
              style: AppTextStyles.newPostText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
>>>>>>> main
      ),
    );
  }
}
