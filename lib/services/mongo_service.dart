import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart'; // Import Helper

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _src = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      final uri = dotenv.env['MONGODB_URI'];
      if (uri == null) throw Exception("URI tidak ditemukan di .env!");

      _db = await Db.create(uri);
      await _db!.open();
      _collection = _db!.collection('logs');
      
      // Smart Logger: Sukses Koneksi
      await LogHelper.writeLog("DATABASE: Berhasil Terhubung ke Cluster", source: _src, level: 2);
    } catch (e) {
      await LogHelper.writeLog("DATABASE: Koneksi Gagal - $e", source: _src, level: 1);
    }
  }

  Future<List<LogModel>> getLogs() async {
    if (_collection == null) await connect();
    // Verbosity Control (Level 3)
    await LogHelper.writeLog("CRUD: Mengambil semua dokumen...", source: _src, level: 3);
    
    final data = await _collection?.find().toList() ?? [];
    return data.map((json) => LogModel.fromMap(json)).toList();
  }

  Future<void> insertLog(Map<String, dynamic> data) async {
    if (_collection == null) await connect();
    await _collection?.insertOne(data);
    await LogHelper.writeLog("CRUD: Menambah data baru: ${data['title']}", source: _src, level: 2);
  }
  
  Future<void> updateLog(LogModel log) async {
    if (_collection == null) await connect();
    if (log.id != null) {
      await _collection!.replaceOne(where.id(log.id!), log.toMap());
      await LogHelper.writeLog("CRUD: Memperbarui data ID: ${log.id}", source: _src, level: 2);
    }
  }

  Future<void> deleteLog(ObjectId id) async {
    if (_collection == null) await connect();
    await _collection!.remove(where.id(id));
    await LogHelper.writeLog("CRUD: Menghapus data ID: $id", source: _src, level: 2);
  }
  
  Future<void> close() async {
    await _db?.close();
    await LogHelper.writeLog("DATABASE: Koneksi ditutup", source: _src, level: 3);
  }
}