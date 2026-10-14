import '../utils/constants.dart';
import 'product.dart';

// 1 dòng trong giỏ hàng = 1 món + size + topping + số lượng
class CartItem {
  final Product product;
  final String size; // 'S', 'M', 'L'
  final List<Topping> toppings;
  final String note; // ghi chú: ít đá, ít ngọt...
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.toppings,
    this.note = '',
    this.quantity = 1,
  });

  // Giá 1 ly = giá gốc + giá size + tổng giá topping
  int get unitPrice {
    final toppingPrice = toppings.fold(0, (sum, t) => sum + t.price);
    return product.price + sizePrices[size]! + toppingPrice;
  }

  // Thành tiền của dòng này
  int get totalPrice => unitPrice * quantity;

  // Tên các topping, ví dụ: "Trân châu đen, Pudding"
  String get toppingNames => toppings.map((t) => t.name).join(', ');

  // Khóa để nhận biết 2 món giống hệt nhau (cùng món, size, topping, ghi chú)
  // -> thêm lần nữa thì chỉ tăng số lượng, không tạo dòng mới
  String get key {
    final toppingIds = toppings.map((t) => t.id).toList()..sort();
    return '${product.id}_${size}_${toppingIds.join(',')}_$note';
  }
}
