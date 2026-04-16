import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId; 
import 'package:logbook_app_001/services/mongo_service.dart';
import 'models/log_model.dart';
import '../../services/access_control_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final MongoService _mongoService = MongoService();
  final _myBox = Hive.box<LogModel>('offline_logs');

  // PERBAIKAN: Constructor untuk memuat data otomatis 
  LogController() {
    _refreshUI(); 
  }

  void _refreshUI() {
    final data = _myBox.values.toList();
    logsNotifier.value = data;
    filteredLogsNotifier.value = data;
  }

  Future<void> loadLogs(String teamId) async {
    try {
      final cloudData = await _mongoService.getLogs(teamId);
      
      // Langkah A: Ambil semua ID yang ada di Cloud
      final cloudIds = cloudData.map((log) => log.id).toSet();

      // Langkah B: Hapus data lokal di Hive yang tidak ada di Cloud 
      // (Kecuali data yang belum sinkron/isSynced == false)
      final localKeys = _myBox.keys;
      for (var key in localKeys) {
        final localLog = _myBox.get(key);
        if (localLog != null && localLog.isSynced && !cloudIds.contains(localLog.id)) {
          await _myBox.delete(key);
        }
      }

      // Langkah C: Update/Tambah data dari Cloud ke Hive
      for (var log in cloudData) {
        await _myBox.put(log.id, log.copyWith(isSynced: true)); 
      }
      
      _refreshUI();
    } catch (e) { 
      debugPrint("Sync Error: $e"); 
    }
  }


  void filterLogs(String query) {
    if (query.isEmpty) {
      filteredLogsNotifier.value = logsNotifier.value;
    } else {
      filteredLogsNotifier.value = logsNotifier.value.where((log) {
        return log.title.toLowerCase().contains(query.toLowerCase()) || 
               log.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> addLog(String title, String desc, String authorId, String teamId, String category, {bool isPublic = false}) async {
    final newId = ObjectId().oid; 
    final newLog = LogModel(
      id: newId, title: title, description: desc, authorId: authorId, teamId: teamId,
      date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      category: category, // Simpan kategori pilihan user
      isSynced: false,
      isPublic: isPublic,
    );
    await _myBox.put(newId, newLog);
    _refreshUI();
    try {
      await _mongoService.insertLog(newLog.toMap());
      await _myBox.put(newId, newLog.copyWith(isSynced: true));
      _refreshUI();
    } catch (e) { debugPrint("Atlas offline"); }
  }

  Future<void> updateLog(LogModel target, String title, String desc, String category, {bool isPublic = false}) async {
    final updated = LogModel(
      id: target.id, title: title, description: desc, authorId: target.authorId,
      teamId: target.teamId, date: target.date, category: category, isSynced: false, isPublic: isPublic,
    );
    await _myBox.put(target.id, updated);
    _refreshUI();
    try {
      await _mongoService.updateLog(updated);
      await _myBox.put(target.id, updated.copyWith(isSynced: true));
    } catch (e) { debugPrint("Update Cloud Gagal"); }
  }

  Future<void> removeLog(LogModel target, String userRole, String userId) async {
    final bool isOwner = target.authorId == userId;
    if (!AccessControlService.canPerform(userRole, 'delete', isOwner: isOwner)) return; 
    
    try {
      // 1. Hapus Cloud DULU
      if (target.id != null) {
        await _mongoService.deleteLog(target.id!);
      }
      // 2. Hapus Lokal
      await _myBox.delete(target.id);
      _refreshUI();
    } catch (e) {
      debugPrint("Gagal hapus permanen. Data mungkin akan muncul lagi saat refresh.");
    }
  }
}