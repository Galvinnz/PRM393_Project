// UNIT TEST: kiểm tra logic giỏ hàng (không cần giao diện, không cần database)
// Chạy: flutter test test/unit
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/cart_provider.dart';

void main() {
  // Dữ liệu mẫu dùng chung cho các test
  final traSua = Product(
    id: 1,
    categoryId: 2,
    name: 'Trà sữa truyền thống',
    description: '',
    price: 35000,
  );
  final tranChau = Topping(id: 1, name: 'Trân châu đen', price: 5000);
  final pudding = Topping(id: 2, name: 'Pudding trứng', price: 8000);

  group('CartItem - tính giá', () {
    test('Size S không topping = giá gốc', () {
      final item = CartItem(product: traSua, size: 'S', toppings: []);
      expect(item.unitPrice, 35000);
    });

    test('Size L + 2 topping, số lượng 2', () {
      final item = CartItem(
        product: traSua,
        size: 'L', // +10.000
        toppings: [tranChau, pudding], // +5.000 +8.000
        quantity: 2,
      );
      expect(item.unitPrice, 58000); // 35.000 + 10.000 + 13.000
      expect(item.totalPrice, 116000); // 58.000 x 2
    });
  });

  group('CartProvider', () {
    late CartProvider cart;

    // Chạy trước mỗi test -> mỗi test có 1 giỏ hàng mới
    setUp(() => cart = CartProvider());

    test('Giỏ hàng mới thì trống', () {
      expect(cart.isEmpty, true);
      expect(cart.totalPrice, 0);
    });

    test('Thêm 2 món giống hệt nhau -> gộp thành 1 dòng, cộng số lượng', () {
      cart.addItem(CartItem(product: traSua, size: 'M', toppings: [tranChau]));
      cart.addItem(CartItem(product: traSua, size: 'M', toppings: [tranChau]));

      expect(cart.items.length, 1);
      expect(cart.itemCount, 2);
      expect(cart.totalPrice, (35000 + 6000 + 5000) * 2);
    });

    test('Khác size -> tách thành 2 dòng', () {
      cart.addItem(CartItem(product: traSua, size: 'S', toppings: []));
      cart.addItem(CartItem(product: traSua, size: 'L', toppings: []));

      expect(cart.items.length, 2);
      expect(cart.totalPrice, 35000 + 45000);
    });

    test('Giảm số lượng về 0 thì món bị xóa khỏi giỏ', () {
      cart.addItem(CartItem(product: traSua, size: 'S', toppings: []));
      cart.decreaseQuantity(cart.items.first);

      expect(cart.isEmpty, true);
    });

    test('clear() xóa hết giỏ hàng', () {
      cart.addItem(CartItem(product: traSua, size: 'S', toppings: []));
      cart.addItem(CartItem(product: traSua, size: 'M', toppings: [pudding]));
      cart.clear();

      expect(cart.isEmpty, true);
      expect(cart.itemCount, 0);
    });
  });

  group('OrderStatus - luồng trạng thái đơn', () {
    test('Chờ xác nhận -> Đã xác nhận -> ... -> Hoàn thành', () {
      expect(OrderStatus.pending.next, OrderStatus.confirmed);
      expect(OrderStatus.confirmed.next, OrderStatus.preparing);
      expect(OrderStatus.preparing.next, OrderStatus.delivering);
      expect(OrderStatus.delivering.next, OrderStatus.completed);
    });

    test('Đơn đã hoàn thành hoặc đã hủy thì không chuyển tiếp được', () {
      expect(OrderStatus.completed.next, isNull);
      expect(OrderStatus.cancelled.next, isNull);
    });
  });
}
