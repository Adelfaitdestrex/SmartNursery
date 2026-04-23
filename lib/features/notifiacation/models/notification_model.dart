class NotificationModel {
  final String notificationId;
  final String userId; // L'utilisateur qui reçoit la notification
  final String type; // 'post', 'comment', 'like', 'mention'
  final String title;
  final String message;
  final String? sourceUserId; // Celui qui a déclenché la notification
  final String? sourceUserName;
  final String? sourceUserProfileImage;
  final String? postId; // Référence au post si applicable
  final bool isRead;
  final DateTime createdAt;
  final String nurseryId;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.sourceUserId,
    this.sourceUserName,
    this.sourceUserProfileImage,
    this.postId,
    this.isRead = false,
    required this.createdAt,
    required this.nurseryId,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'sourceUserId': sourceUserId,
      'sourceUserName': sourceUserName,
      'sourceUserProfileImage': sourceUserProfileImage,
      'postId': postId,
      'isRead': isRead,
      'createdAt': createdAt,
      'nurseryId': nurseryId,
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? docId,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'post',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      sourceUserId: map['sourceUserId'],
      sourceUserName: map['sourceUserName'],
      sourceUserProfileImage: map['sourceUserProfileImage'],
      postId: map['postId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      nurseryId: map['nurseryId'] ?? '',
    );
  }

  // Copy with modifications
  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? sourceUserId,
    String? sourceUserName,
    String? sourceUserProfileImage,
    String? postId,
    bool? isRead,
    DateTime? createdAt,
    String? nurseryId,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      sourceUserId: sourceUserId ?? this.sourceUserId,
      sourceUserName: sourceUserName ?? this.sourceUserName,
      sourceUserProfileImage:
          sourceUserProfileImage ?? this.sourceUserProfileImage,
      postId: postId ?? this.postId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      nurseryId: nurseryId ?? this.nurseryId,
    );
  }
}
