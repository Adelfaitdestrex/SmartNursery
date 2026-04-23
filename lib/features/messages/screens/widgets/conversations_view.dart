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
  // Cache pour éviter le flash lors du rechargement
  Map<String, Timestamp?> _lastActivityByUser = {};
  Map<String, int> _unreadByUser = {};
  bool _hasInitialData = false;
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.messageService.getUserConversations(),
      builder: (context, convSnapshot) {
        // Traiter les données de conversations
        if (convSnapshot.hasData) {
          final convDocs = convSnapshot.data!.docs;
          final Map<String, Timestamp?> newLastActivity = {};
          final Map<String, int> newUnread = {};
 
          for (final convDoc in convDocs) {
            final data = convDoc.data() as Map<String, dynamic>;
            final participantIds = (data['participantIds'] as List)
                .cast<String>();
            final otherUserId = participantIds.firstWhere(
              (id) => id != widget.currentUserId,
              orElse: () => '',
            );
            if (otherUserId.isEmpty) continue;
 
            final updatedAt = data['updatedAt'] as Timestamp?;
            newLastActivity[otherUserId] = updatedAt;
 
            final unreadCount =
                (data['unreadCount'] as Map<String, dynamic>?)?[widget.currentUserId]
                    as int? ??
                0;
            newUnread[otherUserId] = unreadCount;
          }
 
          // Mettre à jour le cache
          _lastActivityByUser = newLastActivity;
          _unreadByUser = newUnread;
          _hasInitialData = true;
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
              
              // Afficher un loader uniquement au premier chargement
              if (!_hasInitialData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFF006F1D)),
                  ),
                )
              else
                UsersListSection(
                  currentUserId: widget.currentUserId,
                  messageService: widget.messageService,
                  lastActivityByUser: _lastActivityByUser,
                  unreadByUser: _unreadByUser,
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}