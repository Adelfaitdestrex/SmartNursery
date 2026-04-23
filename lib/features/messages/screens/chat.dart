import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/messages/services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();
  final _auth = FirebaseAuth.instance;

  // Future qui résout l'ID de conversation (créé ou récupéré)
  late final Future<String> _conversationFuture;

  @override
  void initState() {
    super.initState();
    _conversationFuture = _messageService.getOrCreateConversation(
      widget.otherUserId,
    );
    // Marquer les messages comme lus quand on ouvre la conversation
    _conversationFuture.then((conversationId) {
      _messageService.markMessagesAsRead(conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String conversationId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _messageService.sendMessage(
        conversationId: conversationId,
        content: text,
        recipientId: widget.otherUserId,
      );
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Erreur envoi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur envoi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return "Aujourd'hui";
    if (msgDate == yesterday) return 'Hier';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F2),
      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFD6E6DB)),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  // Retour
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF006F1D),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF91F78E),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          widget.otherUserImage != null &&
                              widget.otherUserImage!.isNotEmpty
                          ? Image.network(
                              widget.otherUserImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildInitialsAvatar(),
                            )
                          : _buildInitialsAvatar(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nom
                  Expanded(
                    child: Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006F1D),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      body: FutureBuilder<String>(
        future: _conversationFuture,
        builder: (context, convSnapshot) {
          // En attente de la création/récupération de la conversation
          if (convSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006F1D)),
            );
          }

          if (convSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Impossible d\'ouvrir la conversation\n${convSnapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final conversationId = convSnapshot.data!;

          return Column(
            children: [
              // ── Liste des messages ──────────────────────────────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messageService.getMessages(conversationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF006F1D),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF6ED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Color(0xFF006F1D),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun message',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF28352E),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Commencez la conversation !',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    // Auto-scroll au dernier message
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msgData =
                            messages[index].data() as Map<String, dynamic>;
                        final senderId = msgData['senderId'] as String? ?? '';
                        final content = msgData['content'] as String? ?? '';
                        final createdAt = msgData['createdAt'] as Timestamp?;
                        final isSent = senderId == _auth.currentUser?.uid;
                        final msgDate = createdAt?.toDate() ?? DateTime.now();

                        // Séparateur de date
                        bool showDate = false;
                        if (index == 0) {
                          showDate = true;
                        } else {
                          final prevData =
                              messages[index - 1].data()
                                  as Map<String, dynamic>;
                          final prevTs = prevData['createdAt'] as Timestamp?;
                          if (prevTs != null) {
                            showDate =
                                _formatDate(prevTs.toDate()) !=
                                _formatDate(msgDate);
                          }
                        }

                        return Column(
                          children: [
                            if (showDate) _buildDateSeparator(msgDate),
                            _buildMessageBubble(
                              content: content,
                              time: _formatTime(msgDate),
                              isSent: isSent,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // ── Zone de saisie ─────────────────────────────────────────────
              _buildInputArea(conversationId),
            ],
          );
        },
      ),
    );
  }

  // ── Widgets helpers ──────────────────────────────────────────────────────

  Widget _buildInitialsAvatar() {
    final initial = widget.otherUserName.isNotEmpty
        ? widget.otherUserName[0].toUpperCase()
        : '?';
    return Container(
      color: const Color(0xFF91F78E),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006F1D),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Color(0xFFD6E6DB), thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECF6ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF546259),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: Color(0xFFD6E6DB), thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String content,
    required String time,
    required bool isSent,
  }) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFF006F1D) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isSent ? 18 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF28352E).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              content,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isSent ? Colors.white : const Color(0xFF28352E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: isSent
                    ? Colors.white.withValues(alpha: 0.65)
                    : const Color(0xFF9CAEA6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(String conversationId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28352E).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Champ de texte
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD6E6DB), width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF28352E),
                ),
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre message…',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF9CAEA6),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Bouton envoyer
          GestureDetector(
            onTap: () => _sendMessage(conversationId),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF006F1D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
