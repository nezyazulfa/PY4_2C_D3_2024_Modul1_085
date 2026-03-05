import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // WAJIB: Tambahkan ini untuk memperbaiki error DateFormat
import 'package:logbook_app_001/services/mongo_service.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final MongoService _mongoService = MongoService();

  Future<void> loadLogs() async {
    try {
      final logs = await _mongoService.getLogs();
      logsNotifier.value = logs;
      filteredLogsNotifier.value = logs; 
    } catch (e) {
      debugPrint("Error loadLogs di Controller: $e");
    }
  }

  void filterLogs(String query) {
    filteredLogsNotifier.value = logsNotifier.value
        .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      // Memperbaiki error baris 31: Sekarang DateFormat sudah dikenali
      date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      category: category,
    );

    await _mongoService.insertLog(newLog.toMap()); 
    await loadLogs(); 
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    try {
      final target = filteredLogsNotifier.value[index];
      final updated = LogModel(
        id: target.id, 
        title: title,
        description: desc,
        // Memperbaiki error baris 47: Sekarang DateFormat sudah dikenali
        date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
        category: category,
      );
      await _mongoService.updateLog(updated);
      await loadLogs();
    } catch (e) {
      debugPrint("Gagal Update: $e");
    }
  }

  Future<void> removeLog(int index) async {
    final target = filteredLogsNotifier.value[index];
    if (target.id != null) {
      await _mongoService.deleteLog(target.id!);
      await loadLogs();
    }
  }
}