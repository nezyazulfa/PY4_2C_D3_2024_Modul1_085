import 'dart:developer' as dev;
import 'dart:io'; // Untuk menulis file
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(String message, {String source = "Unknown", int level = 2}) async {
    // 1. Ambil Konfigurasi dari .env
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    // Verbosity Control: Hanya tampil jika level pesan <= configLevel
    if (level > configLevel) return;
    
    // Source Filtering: Jangan tampil jika source ada di daftar mute
    if (muteList.split(',').map((s) => s.trim()).contains(source)) return;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);
    final dateStr = DateFormat('dd-MM-yyyy').format(now); // Format untuk nama file
    final label = _getLabel(level);
    final color = _getColor(level);

    try {
      // 2. Output ke Terminal (Audit Trail)
      // ignore: avoid_print
      print('$color[$timeStr][$label][$source] -> $message\x1B[0m');

      // 3. Task 4: Simpan ke File (dd-mm-yyyy.log)
      final directory = Directory('logs');
      if (!await directory.exists()) {
        await directory.create(recursive: true); // Buat folder /logs jika belum ada
      }

      final file = File('logs/$dateStr.log');
      final logEntry = '[$timeStr][$label][$source] -> $message\n';
      await file.writeAsString(logEntry, mode: FileMode.append); // Tambahkan ke file yang sudah ada
      
    } catch (e) {
      dev.log("Audit Logging Failed: $e");
    }
  }

  static String _getLabel(int level) => level == 1 ? "ERROR" : level == 2 ? "INFO" : "VERBOSE";

  static String _getColor(int level) {
    switch (level) {
      case 1: return '\x1B[31m'; // Merah
      case 2: return '\x1B[32m'; // Hijau
      default: return '\x1B[34m'; // Biru
    }
  }
}