import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({super.key});

  static const String _foodImage =
      'https://www.figma.com/api/mcp/asset/ebe03044-9c27-4c54-a20d-f38d42c5dd9d';
  static const String _drinkImage =
      'https://www.figma.com/api/mcp/asset/96f7f5ff-f9fc-4e53-a25b-bb88388fc4ee';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.feedCard,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.5,
                  backgroundColor: AppColors.headerTop,
                  child: Text(
                    '+',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mme Dupond',
                      style: TextStyle(
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'il y a 2h',
                      style: TextStyle(
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_horiz, size: 25),
              ],
            ),
          ),
          SizedBox(
            height: 157,
            child: Row(
              children: [
                Expanded(child: Image.network(_foodImage, fit: BoxFit.cover)),
                const SizedBox(width: 2),
                Expanded(child: Image.network(_drinkImage, fit: BoxFit.cover)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                Text('😊', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Text('👏', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Text('❤️', style: TextStyle(fontSize: 16)),
                Spacer(),
                Text(
                  '2 commentaires',
                  style: TextStyle(fontSize: 16, color: Color(0x59000000)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 6, 24, 14),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 25),
                SizedBox(width: 15),
                Text(
                  '3',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Icon(Icons.chat_bubble_outline, size: 25),
                SizedBox(width: 15),
                Text(
                  'Commenter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Icon(Icons.share_outlined, size: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
