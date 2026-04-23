import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/news-feed/screen/create_post_page.dart';

class NewPostContainer extends StatelessWidget {
  const NewPostContainer({super.key});

  static const String _userImageUrl = 'assets/icons/apps-add_logo.png.png';

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(_userImageUrl, fit: BoxFit.cover),
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
      ),
    );
  }
}
