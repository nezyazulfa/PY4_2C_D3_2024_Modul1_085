import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // PENTING: Tambahkan ini agar debugPrint dikenali
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  final String _source = "mongo_service.dart"; // Sekarang kita gunakan di log

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    return _db!.collection('logs');
  }

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      final uri = dotenv.env['MONGODB_URI'];
      if (uri == null) throw Exception("URI tidak ditemukan!");
      _db = await Db.create(uri);
      await _db!.open();
      
      // Menggunakan LogHelper agar warning 'unused import' hilang
      await LogHelper.writeLog("DATABASE: Connected to Cluster", source: _source, level: 2);
    } catch (e) {
      debugPrint("Koneksi Gagal: $e");
    }
  }

  Future<List<LogModel>> getLogs(String teamId) async {
    try {
      final collection = await _getSafeCollection();
      final List<Map<String, dynamic>> data = await collection
          .find(where.eq('teamId', teamId))
          .toList();

      return data.map((json) {
        if (json['_id'] is ObjectId) {
          // FIX: Gunakan .oid sesuai saran warning deprecated
          json['_id'] = (json['_id'] as ObjectId).oid;
        }
        return LogModel.fromMap(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> insertLog(Map<String, dynamic> data) async {
    final collection = await _getSafeCollection();
    // KONVERSI WAJIB: Dari String ID ke ObjectId MongoDB
    if (data['_id'] != null && data['_id'] is String) {
      data['_id'] = ObjectId.fromHexString(data['_id']);
    }
    await collection.insertOne(data);
  }
  
  Future<void> updateLog(LogModel log) async {
    final collection = await _getSafeCollection();
    if (log.id != null) {
      await collection.replaceOne(
        where.id(ObjectId.fromHexString(log.id!)), 
        log.toMap()..['_id'] = ObjectId.fromHexString(log.id!)
      );
    }
  }

  Future<void> deleteLog(String id) async {
    final collection = await _getSafeCollection();
    try {
      // MENCARI BERDASARKAN ObjectId
      final result = await collection.remove(where.id(ObjectId.fromHexString(id)));
      
      // Cek apakah ada yang benar-benar terhapus
      if (result['n'] > 0) {
        debugPrint("Cloud: Data $id berhasil dihapus permanen.");
      } else {
        debugPrint("Peringatan: Data tidak ditemukan di Cloud. Cek apakah di Atlas tipenya String atau ObjectId.");
      }
    } catch (e) {
      debugPrint("Error Delete Cloud: $e");
      rethrow;
    }
  }

  // FIX: Tambahkan fungsi close() agar connection_test.dart tidak error
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      await LogHelper.writeLog("DATABASE: Connection Closed", source: _source, level: 3);
    }
  }
}