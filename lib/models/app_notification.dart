// Thông báo trong app (lưu vào SQLite để xem lại ở màn hình Thông báo)
class AppNotification {
  final int? id;
  final int userId; // thông báo gửi cho user nào
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as int,
      userId: map['userId'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      isRead: map['isRead'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
