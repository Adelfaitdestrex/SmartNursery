import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartnursery/features/messages/screens/chat.dart';
import 'package:smartnursery/features/messages/services/message_service.dart';
import 'conversation_card.dart';

class RecentConversationsSection extends StatelessWidget {
  final String currentUserId;
  final MessageService messageService;

  const RecentConversationsSection({
    super.key,
    required this.currentUserId,
    required this.messageService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageService.getUserConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF006F1D)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFECF6ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.message_outlined,
                  color: Color(0xFF006F1D),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Aucun message pour le moment',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final sortedDocs = _sortConversations(snapshot.data!.docs);

        return Column(
          children: sortedDocs.map((conversationDoc) {
            final conversationData =
                conversationDoc.data() as Map<String, dynamic>;
            final participantIds = (conversationData['participantIds'] as List)
                .cast<String>();
            final otherUserId = participantIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) return const SizedBox.shrink();

            return FutureBuilder<Map<String, dynamic>?>(
              future: messageService.getUserData(otherUserId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final otherUser = userSnapshot.data!;
                final lastMessage = conversationData['lastMessage'];
                final lastMessageText = lastMessage?['content'] ?? '';
                final lastMessageTime = lastMessage?['createdAt'] as Timestamp?;

                String timeString = _formatTimeString(lastMessageTime);

                final firstName = otherUser['firstName'] as String? ?? '';
                final lastName = otherUser['lastName'] as String? ?? '';
                final photoUrl = otherUser['profileImageUrl'] as String? ?? '';

                return FutureBuilder<int>(
                  future: messageService.getUnreadMessageCount(
                    conversationDoc.id,
                  ),
                  builder: (context, unreadSnapshot) {
                    final unreadCount = unreadSnapshot.data ?? 0;

                    return ConversationCard(
                      firstName: firstName,
                      lastName: lastName,
                      photoUrl: photoUrl,
                      unreadCount: unreadCount,
                      lastMessageText: lastMessageText,
                      timeString: timeString,
                      otherUserId: otherUserId,
                      roleColor: const Color(0xFF006F1D),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _sortConversations(
    List<QueryDocumentSnapshot> docs,
  ) {
    final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
    sortedDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aUnread =
          (aData['unreadCount'] as Map<String, dynamic>?)?[currentUserId]
              as int? ??
          0;
      final bUnread =
          (bData['unreadCount'] as Map<String, dynamic>?)?[currentUserId]
              as int? ??
          0;

      if (aUnread != bUnread) {
        return bUnread.compareTo(aUnread);
      }

      final aUpdated = aData['updatedAt'] as Timestamp?;
      final bUpdated = bData['updatedAt'] as Timestamp?;

      if (aUpdated == null && bUpdated == null) return 0;
      if (aUpdated == null) return 1;
      if (bUpdated == null) return -1;
      return bUpdated.compareTo(aUpdated);
    });
    return sortedDocs;
  }

  String _formatTimeString(Timestamp? lastMessageTime) {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final messageDate = lastMessageTime.toDate();
    final difference = now.difference(messageDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${(difference.inDays / 7).toStringAsFixed(0)}sem';
    }
  }
}
