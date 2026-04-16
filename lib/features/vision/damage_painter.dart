import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  final double mockX;
  final double mockY;

  DamagePainter({required this.mockX, required this.mockY});

  @override
  void paint(Canvas canvas, Size size) {
    // Jika size masih nol, jangan menggambar apa pun untuk menghindari error
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Transformasi Koordinat (Scaling Calibration) [cite: 114, 323]
    double centerX = mockX * size.width;
    double centerY = mockY * size.height;
    
    double boxSize = size.width * 0.5; // Kotak berukuran 50% lebar layar
    double left = centerX - (boxSize / 2);
    double top = centerY - (boxSize / 2);

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);
    canvas.drawRect(rect, paint);

    // Teks Label Deteksi [cite: 280]
    final textPainter = TextPainter(
      text: const TextSpan(
        text: " [D40] POTHOLE - 92% ",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.redAccent,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Penempatan teks di atas kotak
    double labelY = top - textPainter.height - 5;
    if (labelY < 0) labelY = top + 5;

    textPainter.paint(canvas, Offset(left, labelY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    // Task 4: Harus true jika koordinat berubah agar kotak bergerak dinamis [cite: 374]
    return oldDelegate.mockX != mockX || oldDelegate.mockY != mockY;
  }
}