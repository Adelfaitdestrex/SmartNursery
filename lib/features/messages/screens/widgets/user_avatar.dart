import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String firstName;
  final Color color;
  final String? photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    required this.firstName,
    required this.color,
    this.photoUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!)
          : null,
      child: photoUrl == null || photoUrl!.isEmpty
          ? _buildInitialsAvatar()
          : null,
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: radius,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
