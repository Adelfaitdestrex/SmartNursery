import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorProfileImageUrl;
  final String content;
  final List<String> mediaUrls;
  final List<String> classIds;
  final List<String> taggedUserIds;
  final List<String> taggedUserNames;
  final String type;
  final Map<String, dynamic> reactions;
  final int commentsCount;
  final bool isPinned;
  final String visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? musicUrl;
  final String? musicTitle;
  final String? musicArtist;

  Post({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorProfileImageUrl = '',
    required this.content,
    this.mediaUrls = const [],
    this.classIds = const [],
    this.taggedUserIds = const [],
    this.taggedUserNames = const [],
    required this.type,
    this.reactions = const {},
    this.commentsCount = 0,
    this.isPinned = false,
    required this.visibility,
    required this.createdAt,
    this.updatedAt,
    this.musicUrl,
    this.musicTitle,
    this.musicArtist,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorProfileImageUrl': authorProfileImageUrl,
      'content': content,
      'mediaUrls': mediaUrls,
      'classIds': classIds,
      'taggedUserIds': taggedUserIds,
      'taggedUserNames': taggedUserNames,
      'type': type,
      'reactions': reactions,
      'commentsCount': commentsCount,
      'isPinned': isPinned,
      'visibility': visibility,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (musicUrl != null) 'musicUrl': musicUrl,
      if (musicTitle != null) 'musicTitle': musicTitle,
      if (musicArtist != null) 'musicArtist': musicArtist,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      postId: documentId,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'] ?? '',
      authorProfileImageUrl: map['authorProfileImageUrl'] ?? '',
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      classIds: List<String>.from(map['classIds'] ?? []),
      taggedUserIds: List<String>.from(map['taggedUserIds'] ?? []),
      taggedUserNames: List<String>.from(map['taggedUserNames'] ?? []),
      type: map['type'] ?? 'announcement',
      reactions: Map<String, dynamic>.from(map['reactions'] ?? {}),
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      isPinned: map['isPinned'] ?? false,
      visibility: map['visibility'] ?? 'all',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      musicUrl: map['musicUrl'],
      musicTitle: map['musicTitle'],
      musicArtist: map['musicArtist'],
    );
  }
}
