import '../data/database_helper.dart';
import '../models/chat_message.dart';

// Đọc/ghi bảng messages
class ChatRepository {
  final _dbHelper = DatabaseHelper.instance;

  // Toàn bộ tin nhắn giữa 1 khách và quán (cũ -> mới)
  Future<List<ChatMessage>> getMessages(int customerId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'messages',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'id ASC',
    );
    return rows.map((row) => ChatMessage.fromMap(row)).toList();
  }

  Future<void> sendMessage(ChatMessage message) async {
    final db = await _dbHelper.database;
    await db.insert('messages', message.toMap()..remove('id'));
  }

  // Danh sách cuộc trò chuyện cho chủ quán:
  // mỗi khách lấy 1 tin nhắn mới nhất (dùng GROUP BY + JOIN)
  Future<List<Conversation>> getConversations() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT m.customerId, u.name, m.content, m.createdAt
      FROM messages m
      JOIN users u ON u.id = m.customerId
      WHERE m.id IN (SELECT MAX(id) FROM messages GROUP BY customerId)
      ORDER BY m.id DESC
    ''');
    return rows.map((row) => Conversation.fromMap(row)).toList();
  }
}
