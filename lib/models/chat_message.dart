import '../utils/constants.dart';

// 1 tin nhắn giữa khách hàng và quán.
// Mỗi khách có 1 cuộc trò chuyện riêng với quán (nhận biết bằng customerId).
class ChatMessage {
  final int? id;
  final int customerId;
  final String sender; // 'customer' hoặc 'shop'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.customerId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  bool get isFromShop => sender == senderShop;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'sender': sender,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int,
      customerId: map['customerId'] as int,
      sender: map['sender'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

// Dùng cho màn hình chủ quán: danh sách các cuộc trò chuyện
class Conversation {
  final int customerId;
  final String customerName;
  final String lastMessage;
  final DateTime lastTime;

  Conversation({
    required this.customerId,
    required this.customerName,
    required this.lastMessage,
    required this.lastTime,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      customerId: map['customerId'] as int,
      customerName: map['name'] as String,
      lastMessage: map['content'] as String,
      lastTime: DateTime.parse(map['createdAt'] as String),
    );
  }
}
