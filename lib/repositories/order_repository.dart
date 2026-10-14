import '../data/database_helper.dart';
import '../models/order.dart';

// Đọc/ghi bảng orders và order_items
class OrderRepository {
  final _dbHelper = DatabaseHelper.instance;

  // Lưu đơn hàng + các món trong đơn.
  // Dùng transaction: nếu lỗi giữa chừng thì không lưu gì cả.
  Future<int> createOrder(Order order, List<OrderItem> items) async {
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap()..remove('id'));
      for (final item in items) {
        final map = item.toMap()
          ..remove('id')
          ..['orderId'] = orderId;
        await txn.insert('order_items', map);
      }
      return orderId;
    });
  }

  // Đơn hàng của 1 khách (mới nhất lên đầu)
  Future<List<Order>> getOrdersByUser(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((row) => Order.fromMap(row)).toList();
  }

  // Tất cả đơn hàng (cho chủ quán)
  Future<List<Order>> getAllOrders() async {
    final db = await _dbHelper.database;
    final rows = await db.query('orders', orderBy: 'id DESC');
    return rows.map((row) => Order.fromMap(row)).toList();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return rows.map((row) => OrderItem.fromMap(row)).toList();
  }

  Future<void> updateStatus(int orderId, OrderStatus status) async {
    final db = await _dbHelper.database;
    await db.update(
      'orders',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}
