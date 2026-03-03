import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;

  factory MongoService() => _instance;
  MongoService._internal();

  Future<void> connect() async {
    final uri = dotenv.env['MONGODB_URI'];
    _db = await Db.create(uri!);
    await _db!.open();
    _collection = _db!.collection('logs');
  }

  // Penting: Kembalikan List<LogModel>, bukan List<Map>
  Future<List<LogModel>> getLogs() async {
    final data = await _collection!.find().toList();
    return data.map((json) => LogModel.fromMap(json)).toList();
  }

  Future<void> insertLog(LogModel log) async => await _collection!.insertOne(log.toMap());
  
  Future<void> updateLog(LogModel log) async {
    if (log.id != null) await _collection!.replaceOne(where.id(log.id!), log.toMap());
  }

  Future<void> deleteLog(ObjectId id) async => await _collection!.remove(where.id(id));
  
  Future<void> close() async => await _db?.close();
}