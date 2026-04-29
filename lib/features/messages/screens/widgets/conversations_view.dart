import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartnursery/features/messages/services/message_service.dart';
import 'users_list_section.dart';

class ConversationsView extends StatefulWidget {
  final String currentUserId;
  final MessageService messageService;

  const ConversationsView({
    super.key,
    required this.currentUserId,
    required this.messageService,
  });

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  bool _useFallbackQuery = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _useFallbackQuery
          ? widget.messageService.getUserConversationsFallback()
          : widget.messageService.getUserConversations(),
      builder: (context, convSnapshot) {
        if (convSnapshot.hasError && !_useFallbackQuery) {
          final errorText = convSnapshot.error.toString().toLowerCase();
          if (errorText.contains('requires an index')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _useFallbackQuery = true;
              });
            });
          }
        }

        final lastActivityByUser = <String, Timestamp?>{};
        final unreadByUser = <String, int>{};

        if (convSnapshot.hasData) {
          for (final convDoc in convSnapshot.data!.docs) {
            final data = convDoc.data() as Map<String, dynamic>;
            final participantIds = (data['participantIds'] as List)
                .cast<String>();
            final otherUserId = participantIds.firstWhere(
              (id) => id != widget.currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) continue;

            lastActivityByUser[otherUserId] = data['updatedAt'] as Timestamp?;
            unreadByUser[otherUserId] =
                (data['unreadCount']
                        as Map<String, dynamic>?)?[widget.currentUserId]
                    as int? ??
                0;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section : Tous les utilisateurs classés par dernier message
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28352E),
                  ),
                ),
              ),

              if (convSnapshot.connectionState == ConnectionState.waiting &&
                  !convSnapshot.hasData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFF006F1D)),
                  ),
                )
              else if (convSnapshot.hasError && !_useFallbackQuery)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Impossible de charger les conversations pour le moment.\n${convSnapshot.error}',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                )
              else
                UsersListSection(
                  currentUserId: widget.currentUserId,
                  messageService: widget.messageService,
                  lastActivityByUser: lastActivityByUser,
                  unreadByUser: unreadByUser,
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
