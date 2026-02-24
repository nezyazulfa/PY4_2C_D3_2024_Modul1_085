class LogModel {
  final String title;
  final String date; // Berfungsi sebagai timestamp 
  final String description;

  LogModel({
    required this.title,
    required this.date,
    required this.description,
  });

  // Konversi Map (JSON) ke Object untuk Task 4 [cite: 93]
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Konversi Object ke Map (JSON) untuk disimpan [cite: 93]
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
    };
  }
}