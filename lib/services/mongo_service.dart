import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  // Fungsi internal untuk memastikan koneksi aman sebelum CRUD
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
      if (uri == null) throw Exception("URI tidak ditemukan di .env!");

      _db = await Db.create(uri);
      await _db!.open();
      
      await LogHelper.writeLog("DATABASE: Berhasil Terhubung ke Cluster", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Koneksi Gagal - $e", source: _source, level: 1);
    }
  }

  // --- LANGKAH 4.1: COLLABORATIVE FILTERING ---
  /// READ: Mengambil data dari Cloud berdasarkan ID Tim
  Future<List<LogModel>> getLogs(String teamId) async {
    try {
      final collection = await _getSafeCollection();

      await LogHelper.writeLog(
        "INFO: Fetching data for Team: $teamId",
        source: _source,
        level: 3,
      );

      // Mencari data yang teamId-nya COCOK dengan tim user yang login
      final List<Map<String, dynamic>> data = await collection
          .find(where.eq('teamId', teamId)) // Filter Berdasarkan Tim
          .toList();

      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Fetch Failed - $e",
        source: _source,
        level: 1,
      );
      return [];
    }
  }

  Future<void> insertLog(Map<String, dynamic> data) async {
    final collection = await _getSafeCollection();
    await collection.insertOne(data);
    await LogHelper.writeLog("CRUD: Menambah data baru ke Cloud: ${data['title']}", source: _source, level: 2);
  }
  
  Future<void> updateLog(LogModel log) async {
    final collection = await _getSafeCollection();
    if (log.id != null) {
      await collection.replaceOne(
        where.id(ObjectId.fromHexString(log.id!)), 
        log.toMap()
      );
      await LogHelper.writeLog("CRUD: Memperbarui data ID: ${log.id}", source: _source, level: 2);
    }
  }

  Future<void> deleteLog(String id) async {
    final collection = await _getSafeCollection();
    try {
      await collection.remove(where.id(ObjectId.fromHexString(id)));
      await LogHelper.writeLog("CRUD: Menghapus data ID: $id dari Cloud", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal hapus di Cloud - $e", source: _source, level: 1);
    }
  }
  
  Future<void> close() async {
    await _db?.close();
    await LogHelper.writeLog("DATABASE: Koneksi ditutup", source: _source, level: 3);
  }
}