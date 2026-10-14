import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../repositories/notification_repository.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';

// Quản lý đơn hàng: đặt hàng, lịch sử đơn, chủ quán cập nhật trạng thái
class OrderProvider extends ChangeNotifier {
  final _orderRepo = OrderRepository();
  final _notificationRepo = NotificationRepository();

  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // Khách hàng: chỉ lấy đơn của mình
  Future<void> loadMyOrders(int userId) async {
    _isLoading = true;
    notifyListeners();
    _orders = await _orderRepo.getOrdersByUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Chủ quán: lấy tất cả đơn
  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _orderRepo.getAllOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) {
    return _orderRepo.getOrderItems(orderId);
  }

  // Đặt hàng từ giỏ hàng. Trả về mã đơn vừa tạo.
  Future<int> placeOrder({
    required User user,
    required List<CartItem> cartItems,
    required String customerName,
    required String phone,
    required String address,
    required String note,
    required PaymentMethod paymentMethod,
  }) async {
    final total = cartItems.fold(0, (sum, item) => sum + item.totalPrice);

    final order = Order(
      userId: user.id!,
      customerName: customerName,
      phone: phone,
      address: address,
      note: note,
      paymentMethod: paymentMethod,
      // Thanh toán online (giả lập) đã thành công trước khi gọi hàm này
      isPaid: paymentMethod != PaymentMethod.cash,
      totalPrice: total,
      createdAt: DateTime.now(),
    );

    // Chuyển CartItem -> OrderItem để lưu vào database
    final orderItems = cartItems
        .map((c) => OrderItem(
              productName: c.product.name,
              size: c.size,
              toppings: c.toppingNames,
              note: c.note,
              quantity: c.quantity,
              unitPrice: c.unitPrice,
            ))
        .toList();

    final orderId = await _orderRepo.createOrder(order, orderItems);
    await _notify(
      user.id!,
      'Đặt hàng thành công',
      'Đơn #$orderId: ${OrderStatus.pending.message}',
    );
    return orderId;
  }

  // Đổi trạng thái đơn (chủ quán chuyển bước, hoặc khách hủy đơn)
  Future<void> updateStatus(Order order, OrderStatus newStatus) async {
    await _orderRepo.updateStatus(order.id!, newStatus);

    // Báo cho khách hàng biết trạng thái mới
    await _notify(
      order.userId,
      'Đơn #${order.id}: ${newStatus.label}',
      newStatus.message,
    );

    // Cập nhật lại đơn trong danh sách đang hiển thị
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order.copyWith(status: newStatus);
    }
    notifyListeners();
  }

  // Gọi khi đăng xuất
  void clear() {
    _orders = [];
    notifyListeners();
  }

  // Lưu thông báo vào database (để xem ở màn Thông báo)
  // + hiện thông báo hệ thống trên điện thoại
  Future<void> _notify(int userId, String title, String body) async {
    await _notificationRepo.insert(AppNotification(
      userId: userId,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    ));
    await NotificationService.instance.show(title, body);
  }
}
