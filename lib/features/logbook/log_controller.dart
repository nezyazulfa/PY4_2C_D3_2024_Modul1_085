import 'dart:convert'; // Library wajib untuk jsonEncode & jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  // Notifier reaktif agar UI otomatis terupdate (Task 3)
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier<List<LogModel>>([]);
  static const String _storageKey = 'user_logs_data';

  LogController() {
    loadFromDisk(); // Restoration: Memuat data saat aplikasi dibuka
  }

  void addLog(String title, String desc) {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
    );
    logsNotifier.value = [...logsNotifier.value, newLog]; 
    saveToDisk(); // Menyimpan setiap ada perubahan
  }

  void updateLog(int index, String title, String desc) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
    );
    logsNotifier.value = currentLogs;
    saveToDisk(); 
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToDisk();
  }

  // --- TASK 4: VERIFIKASI ENCODING (OBJECT -> JSON) ---
  Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mengonversi List of LogModel menjadi String JSON
      final String encodedData = jsonEncode(
        logsNotifier.value.map((e) => e.toMap()).toList(),
      );
      
      // Bukti Encoding Berhasil: Muncul di Debug Console
      debugPrint("✅ ENCODING SUCCESS: $encodedData");
      
      await prefs.setString(_storageKey, encodedData); // Simpan ke memori lokal
    } catch (e) {
      debugPrint("❌ ENCODING ERROR: $e");
    }
  }

  // --- TASK 4: VERIFIKASI DECODING (JSON -> OBJECT) ---
  Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      // Bukti Data Ditemukan di Disk
      debugPrint("📂 DATA FROM DISK: $data");

      if (data != null) {
        // Decoding String JSON kembali menjadi List
        final List decoded = jsonDecode(data); 
        
        // Bukti Decoding Berhasil: Menghitung jumlah item
        debugPrint("✅ DECODING SUCCESS: Berhasil memuat ${decoded.length} catatan.");
        
        // Mengubah kembali data Map menjadi Object LogModel
        logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ DECODING ERROR: $e");
    }
  }
}