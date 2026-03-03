import 'package:mongo_dart/mongo_dart.dart'; // Wajib import ini

class LogModel {
  final ObjectId? id; // Menggunakan tipe data ObjectId dari mongo_dart
  final String title;
  final String description;
  final String category;
  final String date;

  LogModel({this.id, required this.title, required this.description, required this.category, required this.date});

  // Mapping _id dari MongoDB ke properti 'id' di Dart
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?, // MongoDB menggunakan field '_id'
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id, // Hanya kirim _id jika sudah ada di database
      'title': title,
      'description': description,
      'category': category,
      'date': date,
    };
  }
}