import 'package:flutter/material.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final MongoService _mongoService = MongoService();

  // Ganti loadFromDisk menjadi loadLogs agar sinkron dengan LogView
  Future<void> loadLogs() async {
    final logs = await _mongoService.getLogs();
    logsNotifier.value = logs;
    filteredLogsNotifier.value = logs;
  }

  void filterLogs(String query) {
    filteredLogsNotifier.value = logsNotifier.value
        .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // PENTING: Gunakan Future<void> agar bisa di-await di UI
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );
    await _mongoService.insertLog(newLog);
    await loadLogs(); // Refresh data
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    final target = filteredLogsNotifier.value[index];
    final updated = LogModel(
      id: target.id, 
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );
    await _mongoService.updateLog(updated);
    await loadLogs();
  }

  Future<void> removeLog(int index) async {
    final target = filteredLogsNotifier.value[index];
    if (target.id != null) {
      await _mongoService.deleteLog(target.id!);
      await loadLogs();
    }
  }
}