import 'package:flutter/material.dart';
import 'package:smartnursery/features/messages/screens/chat.dart';

class ConversationCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String photoUrl;
  final int unreadCount;
  final String lastMessageText;
  final String timeString;
  final String otherUserId;
  final Color roleColor;

  const ConversationCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.unreadCount,
    required this.lastMessageText,
    required this.timeString,
    required this.otherUserId,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: otherUserId,
            otherUserName: '$firstName $lastName',
            otherUserImage: photoUrl,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unreadCount > 0 ? const Color(0xFFF0F7F2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unreadCount > 0
                ? const Color(0xFF91F78E)
                : const Color(0xFFD6E6DB),
            width: unreadCount > 0 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF28352E).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatarWithBadge(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameRow(),
                  const SizedBox(height: 4),
                  _buildLastMessageText(),
                ],
              ),
            ),
            _buildTimeContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithBadge() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF91F78E), width: 2),
          ),
          child: ClipOval(
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildInitialsAvatar(firstName, roleColor),
                  )
                : _buildInitialsAvatar(firstName, roleColor),
          ),
        ),
        if (unreadCount > 0) _buildUnreadBadge(),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    return Positioned(
      top: -2,
      right: -2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFE74C3C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE74C3C),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$firstName $lastName',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: unreadCount > 0
                  ? const Color(0xFF006F1D)
                  : const Color(0xFF28352E),
            ),
          ),
        ),
        if (unreadCount > 0) _buildUnreadIndicator(),
      ],
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFE74C3C),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0xFFE74C3C), blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _buildLastMessageText() {
    return Text(
      lastMessageText.length > 45
          ? '${lastMessageText.substring(0, 45)}...'
          : lastMessageText,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: unreadCount > 0
            ? const Color(0xFF006F1D)
            : const Color(0xFF546259),
        fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTimeContainer() {
    if (timeString.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: unreadCount > 0
            ? const Color(0xFFE74C3C)
            : const Color(0xFFECF6ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        timeString,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: unreadCount > 0 ? Colors.white : const Color(0xFF006F1D),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String firstName, Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
