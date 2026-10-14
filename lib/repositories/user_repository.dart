import '../data/database_helper.dart';
import '../models/user.dart';

// Đọc/ghi bảng users
class UserRepository {
  final _dbHelper = DatabaseHelper.instance;

  // Đăng ký: trả về false nếu email đã tồn tại
  Future<bool> register(User user) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );
    if (existing.isNotEmpty) return false;

    final map = user.toMap()..remove('id'); // id do SQLite tự tăng
    await db.insert('users', map);
    return true;
  }

  // Đăng nhập: đúng email + mật khẩu thì trả về User, sai thì null
  Future<User?> login(String email, String password) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  // Cập nhật họ tên, số điện thoại, mật khẩu (email dùng để đăng nhập nên không đổi)
  Future<void> updateUser(User user) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'name': user.name, 'phone': user.phone, 'password': user.password},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }
}
