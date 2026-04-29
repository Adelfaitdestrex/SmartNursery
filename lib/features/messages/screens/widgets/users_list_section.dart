import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartnursery/features/messages/screens/chat.dart';
import 'package:smartnursery/features/messages/services/message_service.dart';

class UsersListSection extends StatelessWidget {
  final String currentUserId;
  final MessageService messageService;
  final Map<String, Timestamp?> lastActivityByUser;
  final Map<String, int> unreadByUser;

  const UsersListSection({
    super.key,
    required this.currentUserId,
    required this.messageService,
    required this.lastActivityByUser,
    required this.unreadByUser,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageService.getAllUsers(),
      builder: (context, usersSnapshot) {
        if (usersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF006F1D)),
            ),
          );
        }

        if (usersSnapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Erreur chargement utilisateurs: ${usersSnapshot.error}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          );
        }

        final docs =
            usersSnapshot.data?.docs
                .where((d) => d.id != currentUserId)
                .toList() ??
            [];

        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          );
        }

        // CORRECTION : Trier IMMÉDIATEMENT avant de construire les widgets
        final sortedDocs = _sortUsers(docs);

        return Column(
          children: sortedDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final firstName = data['firstName'] as String? ?? '';
            final lastName = data['lastName'] as String? ?? '';
            final photoUrl = data['profileImageUrl'] as String? ?? '';
            final role = data['role'] as String? ?? '';
            final unreadCount = unreadByUser[doc.id] ?? 0;

            final (roleColor, roleLabel) = _getRoleInfo(role);

            return _buildUserCard(
              context: context,
              userId: doc.id,
              firstName: firstName,
              lastName: lastName,
              photoUrl: photoUrl,
              roleColor: roleColor,
              roleLabel: roleLabel,
              unreadCount: unreadCount,
            );
          }).toList(),
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _sortUsers(List<QueryDocumentSnapshot> docs) {
    final sortedDocs = List<QueryDocumentSnapshot>.from(docs);

    // Créer un index pour maintenir l'ordre original en cas d'égalité
    final indexById = <String, int>{
      for (var i = 0; i < docs.length; i++) docs[i].id: i,
    };

    sortedDocs.sort((a, b) {
      // 1. PRIORITÉ ABSOLUE : Messages non lus (ordre décroissant)
      final aUnread = unreadByUser[a.id] ?? 0;
      final bUnread = unreadByUser[b.id] ?? 0;

      if (aUnread > 0 || bUnread > 0) {
        // Si l'un a des non lus et pas l'autre, celui avec non lus vient en premier
        if (aUnread > 0 && bUnread == 0) return -1;
        if (bUnread > 0 && aUnread == 0) return 1;
        // Si les deux ont des non lus, trier par nombre décroissant
        if (aUnread != bUnread) return bUnread.compareTo(aUnread);
      }

      // 2. DEUXIÈME PRIORITÉ : Conversations existantes (avec activité)
      final aTs = lastActivityByUser[a.id];
      final bTs = lastActivityByUser[b.id];

      // Si l'un a une conversation et pas l'autre
      if (aTs != null && bTs == null) return -1; // a en premier
      if (bTs != null && aTs == null) return 1; // b en premier

      // Si les deux ont une conversation, trier par date (plus récent en premier)
      if (aTs != null && bTs != null) {
        final tsComparison = bTs.compareTo(aTs);
        if (tsComparison != 0) return tsComparison;
      }

      // 3. DERNIÈRE PRIORITÉ : Utilisateurs sans conversation (ordre alphabétique)
      if (aTs == null && bTs == null) {
        // Garder l'ordre original de Firestore ou trier alphabétiquement
        return (indexById[a.id] ?? 0).compareTo(indexById[b.id] ?? 0);
      }

      // 4. En cas d'égalité parfaite, garder l'ordre original
      return (indexById[a.id] ?? 0).compareTo(indexById[b.id] ?? 0);
    });

    return sortedDocs;
  }

  (Color, String) _getRoleInfo(String? role) {
    switch (role) {
      case 'educator':
        return (const Color(0xFF0057A8), 'Enseignant');
      case 'admin':
        return (const Color(0xFFB45300), 'Administrateur');
      case 'director':
        return (const Color(0xFF7C3AED), 'Directeur');
      default:
        return (const Color(0xFF006F1D), 'Parent');
    }
  }

  Widget _buildUserCard({
    required BuildContext context,
    required String userId,
    required String firstName,
    required String lastName,
    required String photoUrl,
    required Color roleColor,
    required String roleLabel,
    required int unreadCount,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: userId,
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
            _buildAvatarWithBadge(
              photoUrl: photoUrl,
              firstName: firstName,
              roleColor: roleColor,
              unreadCount: unreadCount,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildUserInfo(
                firstName: firstName,
                lastName: lastName,
                roleColor: roleColor,
                roleLabel: roleLabel,
                unreadCount: unreadCount,
              ),
            ),
            _buildMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithBadge({
    required String photoUrl,
    required String firstName,
    required Color roleColor,
    required int unreadCount,
  }) {
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
        if (unreadCount > 0) _buildUnreadBadge(unreadCount),
      ],
    );
  }

  Widget _buildUnreadBadge(int unreadCount) {
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

  Widget _buildUserInfo({
    required String firstName,
    required String lastName,
    required Color roleColor,
    required String roleLabel,
    required int unreadCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            if (unreadCount > 0)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE74C3C),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roleLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF006F1D),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
    );
  }
}
