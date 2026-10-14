import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/format.dart';
import '../../utils/validators.dart';
import '../../widgets/fake_payment_dialog.dart';

// Đặt hàng: nhập thông tin nhận hàng + chọn cách thanh toán
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn tên + SĐT từ tài khoản
    final user = context.read<AuthProvider>().currentUser!;
    _nameController.text = user.name;
    _phoneController.text = user.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Lấy provider trước các lệnh await
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final user = context.read<AuthProvider>().currentUser!;

    // 1. Thanh toán online -> mở hộp thoại thanh toán giả lập
    if (_paymentMethod != PaymentMethod.cash) {
      final paid = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // bắt buộc bấm Hủy hoặc Thanh toán
        builder: (_) => FakePaymentDialog(
          method: _paymentMethod,
          amount: cart.totalPrice,
        ),
      );
      if (paid != true) return; // khách bấm Hủy
    }

    // 2. Lưu đơn hàng vào database
    setState(() => _isLoading = true);
    final orderId = await orderProvider.placeOrder(
      user: user,
      cartItems: cart.items,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      note: _noteController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    // 3. Cập nhật số thông báo chưa đọc (vừa có thông báo "Đặt hàng thành công")
    await notificationProvider.loadNotifications(user.id!);
    if (!mounted) return;

    // 4. Báo thành công
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Đặt hàng thành công!'),
        content: Text(
          'Mã đơn hàng: #$orderId\n'
          'Bạn có thể theo dõi trạng thái ở tab "Đơn hàng".',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    // 5. Xóa giỏ hàng và quay về màn hình chính
    cart.clear();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt hàng')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Thông tin nhận hàng'),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Người nhận',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: validatePhone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: validateAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú cho quán (không bắt buộc)',
                prefixIcon: Icon(Icons.note_alt),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Phương thức thanh toán'),
            RadioGroup<PaymentMethod>(
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
              child: Column(
                children: PaymentMethod.values.map((method) {
                  return RadioListTile<PaymentMethod>(
                    value: method,
                    title: Text(method.label),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            _buildSectionTitle('Món đã chọn (${cart.itemCount} ly)'),
            ...cart.items.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text('${item.quantity} x ${item.product.name} (${item.size})'),
                subtitle: item.toppings.isEmpty ? null : Text(item.toppingNames),
                trailing: Text(formatVnd(item.totalPrice)),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng thanh toán'),
                  Text(
                    formatVnd(cart.totalPrice),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isLoading ? null : _placeOrder, // khóa nút khi đang xử lý
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Xác nhận đặt hàng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
