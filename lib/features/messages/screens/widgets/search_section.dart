import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/messages/screens/chat.dart';
import 'package:smartnursery/features/messages/services/message_service.dart';

class SearchSection extends StatefulWidget {
  final String searchQuery;

  const SearchSection({super.key, required this.searchQuery});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final MessageService _messageService = MessageService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch() async {
    final query = widget.searchQuery;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _messageService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(SearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _performSearch();
    }
  }

  Future<void> _openChat(Map<String, dynamic> user) async {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            otherUserId: user['id'],
            otherUserName: '${user['firstName']} ${user['lastName']}',
            otherUserImage: user['profileImageUrl'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur trouvé',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildSearchResultCard(user);
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () => _openChat(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            _buildUserAvatar(user),
            const SizedBox(width: 12),
            Expanded(child: _buildUserInfo(user)),
            _buildMessageButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    return CircleAvatar(
      radius: 28,
      backgroundImage:
          user['profileImageUrl'] != null && user['profileImageUrl'].isNotEmpty
          ? NetworkImage(user['profileImageUrl'])
          : null,
      child: user['profileImageUrl'] == null || user['profileImageUrl'].isEmpty
          ? Text(
              (user['firstName'] as String).isNotEmpty
                  ? user['firstName'][0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 18),
            )
          : null,
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user['firstName']} ${user['lastName']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          user['role'] ?? 'Utilisateur',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMessageButton(Map<String, dynamic> user) {
    return ElevatedButton(
      onPressed: () => _openChat(user),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        'Message',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
