import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  // 1. Inisialisasi ValueNotifier untuk manajemen list secara reaktif 
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier<List<LogModel>>([]);
  static const String _storageKey = 'user_logs_data';

  LogController() {
    loadFromDisk(); // Memuat data saat controller pertama kali dibuat 
  }

  // 2. Logika Tambah Data (Create) [cite: 99, 166]
  void addLog(String title, String desc) {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), // Mengenerate timestamp otomatis [cite: 99, 165]
    );
    
    // Memperbarui list secara reaktif tanpa perlu memanggil setState di View [cite: 99, 176]
    logsNotifier.value = [...logsNotifier.value, newLog]; 
    saveToDisk(); // Otomatis menyimpan ke memori lokal [cite: 99, 185]
  }

  // 3. Logika Update Data (Update) - Menjaga Integritas Data [cite: 99, 112, 177]
  void updateLog(int index, String title, String desc) {
    // Membuat salinan list baru agar ValueNotifier mendeteksi perubahan referensi 
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    
    currentLogs[index] = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), // Update waktu edit 
    );
    
    logsNotifier.value = currentLogs; // Memicu update UI otomatis di View [cite: 176]
    saveToDisk(); 
  }

  // 4. Logika Hapus Data (Delete) [cite: 99, 166]
  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index); // Menghapus item berdasarkan index [cite: 99, 166]
    
    logsNotifier.value = currentLogs; 
    saveToDisk();
  }

  // 5. Serialization: Mengubah List Object menjadi JSON String (Task 4) [cite: 99, 184]
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData); // Simpan permanen [cite: 99, 185]
  }

  // 6. Restoration: Mengubah JSON String kembali menjadi List Object (Task 4) [cite: 99, 186]
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    
    if (data != null) {
      final List decoded = jsonDecode(data); // Decoding JSON [cite: 99, 189]
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList(); // Map ke Object 
    }
  }
}