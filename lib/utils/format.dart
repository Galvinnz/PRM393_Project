// Định dạng tiền VND: 35000 -> "35.000 đ"
String formatVnd(num amount) {
  final s = amount.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return '${buffer.toString()} đ';
}

// Định dạng ngày giờ: "09:05 13/10/2026"
String formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.hour)}:${two(dt.minute)} ${two(dt.day)}/${two(dt.month)}/${dt.year}';
}
