import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  final double mockX;
  final double mockY;
  final String damageType; // Menerima tipe kerusakan dari Controller

  DamagePainter({
    required this.mockX, 
    required this.mockY, 
    required this.damageType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // ==========================================
    // 1. DYNAMIC COLOR BRANDING (Visual Hierarchy)
    // ==========================================
    // Jika D40 = Merah (Bahaya/Berat), selain itu (D00) = Kuning (Peringatan/Ringan)
    Color themeColor = damageType == 'D40' ? Colors.redAccent : Colors.amberAccent;
    String labelText = damageType == 'D40' ? " [D40] POTHOLE " : " [D00] CRACK ";

    final paint = Paint()
      ..color = themeColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    double centerX = mockX * size.width;
    double centerY = mockY * size.height;
    
    double boxSize = size.width * 0.5;
    double left = centerX - (boxSize / 2);
    double top = centerY - (boxSize / 2);

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);
    canvas.drawRect(rect, paint);

    // ==========================================
    // 2. TEXT READABILITY (Shadow / Stroke Effect)
    // ==========================================
    final textPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: themeColor, // Warna teks mengikuti warna kotak
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          // Efek Stroke/Shadow Hitam pekat agar teks menonjol di aspal putih/hitam
          shadows: const [
            Shadow(offset: Offset(-1.5, -1.5), color: Colors.black87, blurRadius: 2),
            Shadow(offset: Offset(1.5, -1.5), color: Colors.black87, blurRadius: 2),
            Shadow(offset: Offset(1.5, 1.5), color: Colors.black87, blurRadius: 2),
            Shadow(offset: Offset(-1.5, 1.5), color: Colors.black87, blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double labelY = top - textPainter.height - 8;
    if (labelY < 0) labelY = top + 8;

    textPainter.paint(canvas, Offset(left, labelY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    // Harus repaint jika koordinat ATAU tipe kerusakannya berubah
    return oldDelegate.mockX != mockX || 
           oldDelegate.mockY != mockY || 
           oldDelegate.damageType != damageType;
  }
}