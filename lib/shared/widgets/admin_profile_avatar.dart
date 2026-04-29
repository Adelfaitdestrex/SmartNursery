import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Avatar circulaire du current user à afficher dans les headers admin.
/// Charge la photo depuis Firestore en temps réel.
class AdminProfileAvatar extends StatelessWidget {
  final double size;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AdminProfileAvatar({
    super.key,
    this.size = 40,
    this.borderColor = const Color(0xFF91F78E),
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return _buildAvatar(null);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String? imageUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          imageUrl = data?['profileImageUrl'] as String?;
        }
        return GestureDetector(
          onTap: onTap,
          child: _buildAvatar(imageUrl),
        );
      },
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        color: const Color(0xFFD6E6DB),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: size * 0.55,
              color: const Color(0xFF006F1D),
            )
          : null,
    );
  }
}
