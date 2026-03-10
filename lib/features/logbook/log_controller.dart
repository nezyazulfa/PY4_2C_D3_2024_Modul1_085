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

  Future<void> loadLogs(String teamId) async {
    _refreshUI();
    try {
      final cloudData = await _mongoService.getLogs(teamId);
      for (var log in cloudData) {
        await _myBox.put(log.id, log.copyWith(isSynced: true)); 
      }
      final pendingLogs = _myBox.values.where((l) => l.isSynced == false).toList();
      for (var localLog in pendingLogs) {
        try {
          await _mongoService.insertLog(localLog.toMap());
          await _myBox.put(localLog.id, localLog.copyWith(isSynced: true));
        } catch (e) { debugPrint("Sync fail: $e"); }
      }
      _refreshUI();
    } catch (e) { debugPrint("Offline: $e"); }
  }

  void _refreshUI() {
    final data = _myBox.values.toList();
    logsNotifier.value = data;
    filteredLogsNotifier.value = data;
  }

  void filterLogs(String query) {
    filteredLogsNotifier.value = logsNotifier.value
        .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // UPDATE: Tambah parameter isPublic
  Future<void> addLog(String title, String desc, String authorId, String teamId, {bool isPublic = false}) async {
    final newId = ObjectId().oid; 
    final newLog = LogModel(
      id: newId, title: title, description: desc, authorId: authorId, teamId: teamId,
      date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      isSynced: false,
      isPublic: isPublic, // Set sesuai input user
    );
    await _myBox.put(newId, newLog);
    _refreshUI();
    try {
      await _mongoService.insertLog(newLog.toMap());
      await _myBox.put(newId, newLog.copyWith(isSynced: true));
      _refreshUI();
    } catch (e) { debugPrint("Atlas offline"); }
  }

  // UPDATE: Tambah parameter isPublic
  Future<void> updateLog(int index, String title, String desc, String category, {bool isPublic = false}) async {
    try {
      final target = filteredLogsNotifier.value[index];
      final updated = LogModel(
        id: target.id, title: title, description: desc, authorId: target.authorId,
        teamId: target.teamId, date: target.date, category: category, 
        isSynced: false, isPublic: isPublic, // Set sesuai input user
      );
      await _myBox.put(target.id, updated);
      await _mongoService.updateLog(updated);
      _refreshUI();
    } catch (e) { debugPrint("Update fail: $e"); }
  }

  Future<void> removeLog(int index, String userRole, String userId) async {
    final target = filteredLogsNotifier.value[index]; 
    if (!AccessControlService.canPerform(userRole, 'delete', isOwner: target.authorId == userId)) return; 
    try {
      await _myBox.delete(target.id);
      if (target.id != null) await _mongoService.deleteLog(target.id!);
      _refreshUI();
    } catch (e) { debugPrint("Delete fail: $e"); }
  }
}