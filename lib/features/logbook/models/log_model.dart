import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String date;
  @HiveField(4)
  final String authorId;
  @HiveField(5)
  final String teamId;
  @HiveField(6)
  final String category;
  @HiveField(7)
  final bool isSynced;
  @HiveField(8)
  final bool isPublic; // TASK 5: Field Baru

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.authorId,
    required this.teamId,
    this.category = 'Software',
    this.isSynced = false,
    this.isPublic = false, // Default: Privat
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'date': date,
      'authorId': authorId,
      'teamId': teamId,
      'category': category,
      'isPublic': isPublic, // Simpan status ke Cloud
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      authorId: map['authorId'],
      teamId: map['teamId'],
      category: map['category'] ?? 'Software',
      isSynced: true,
      isPublic: map['isPublic'] ?? false, // Ambil status dari Cloud
    );
  }

  LogModel copyWith({bool? isSynced, bool? isPublic}) {
    return LogModel(
      id: id,
      title: title,
      description: description,
      date: date,
      authorId: authorId,
      teamId: teamId,
      category: category,
      isSynced: isSynced ?? this.isSynced,
      isPublic: isPublic ?? this.isPublic, // Update status publik
    );
  }
}