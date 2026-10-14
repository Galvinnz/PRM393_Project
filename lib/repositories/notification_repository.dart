import '../data/database_helper.dart';
import '../models/app_notification.dart';

// Đọc/ghi bảng notifications
class NotificationRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> insert(AppNotification notification) async {
    final db = await _dbHelper.database;
    await db.insert('notifications', notification.toMap()..remove('id'));
  }

  Future<List<AppNotification>> getByUser(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((row) => AppNotification.fromMap(row)).toList();
  }

  Future<void> markAsRead(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead(int userId) async {
    final db = await _dbHelper.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
