class Notification {
  final String id;
  final String user;
  final String type;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.user,
    required this.type,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? json['id'] ?? '',
      user: json['user'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'type': type,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
