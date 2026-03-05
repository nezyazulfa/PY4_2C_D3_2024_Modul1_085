import 'dart:io';
import 'package:flutter/foundation.dart'; // Tambahkan ini untuk debugPrint
import 'package:path_provider/path_provider.dart'; // Sekarang ini tidak akan merah lagi
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(String message, {String source = "Unknown", int level = 2}) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    if (level > configLevel) return;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);
    final dateStr = DateFormat('dd-MM-yyyy').format(now);

    try {
      // Mencari folder dokumen internal di Android agar tidak Read-only
      final Directory directory = await getApplicationDocumentsDirectory();
      final String logDirPath = '${directory.path}/logs';
      final Directory logDir = Directory(logDirPath);
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final file = File('$logDirPath/$dateStr.log');
      final logEntry = '[$timeStr][$source] -> $message\n';
      await file.writeAsString(logEntry, mode: FileMode.append);
      
      // Gunakan debugPrint untuk menghilangkan warning "avoid_print"
      debugPrint('[$timeStr][LOG] -> $message');
      
    } catch (e) {
      debugPrint("Gagal menulis log ke file: $e");
    }
  }
}