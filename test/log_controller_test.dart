import 'dart:io'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

void main() {
  // Path sementara untuk database testing agar tidak mengganggu data asli
  final tempPath = '${Directory.current.path}/test/hive_temp';

  setUpAll(() async {
    // 1. Inisialisasi Hive di folder temp 
    Hive.init(tempPath);
    
    // 2. Register Adapter LogModel 
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LogModelAdapter());
    }
  });

  setUp(() async {
    // 3. Pastikan box terbuka sebelum tes dijalankan 
    await Hive.openBox<LogModel>('offline_logs');
  });

  tearDown(() async {
    // 4. Bersihkan data dan tutup box setelah tes [cite: 799]
    final box = Hive.box<LogModel>('offline_logs');
    if (box.isOpen) {
      await box.clear();
      await box.close();
    }
    
    // Hapus folder temp secara rekursif
    final dir = Directory(tempPath);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('LogController Modul 3 (Hive Persistence) Tests', () {
    
    // TC-M3-01: Positif - Model Serialization [cite: 757, 764]
    test('TC-M3-01 - LogModel should convert to/from map correctly', () {
      final originalLog = LogModel(
        title: 'Kuliah PR4',
        description: 'Belajar Testing',
        date: '31-03-2026 10:00',
        authorId: 'nezya085',
        teamId: 'team_proyek4',
        isPublic: true,
      );

      final mapResult = originalLog.toMap();
      final decodedLog = LogModel.fromMap(mapResult);

      expect(decodedLog.title, 'Kuliah PR4');
      expect(decodedLog.authorId, 'nezya085');
      expect(decodedLog.isPublic, true);
    });

    // TC-M3-02: Positif - Save Data to Hive [cite: 786, 800]
    test('TC-M3-02 - addLog should save data to Hive Box', () async {
      final controller = LogController();

      await controller.addLog(
        'Tugas 1', 
        'Selesai', 
        'nezya085', 
        'team_proyek4', 
        'Software'
      );

      // Verifikasi Notifier UI [cite: 817, 820]
      expect(controller.logsNotifier.value.length, 1);
      
      // Verifikasi Database Hive secara langsung [cite: 805, 806]
      final box = Hive.box<LogModel>('offline_logs');
      expect(box.isNotEmpty, true);
      expect(box.values.first.title, 'Tugas 1');
    });

    // TC-M3-03: Positif - Data Restoration [cite: 697, 740, 812]
    test('TC-M3-03 - LogController should load existing data from Hive on init', () async {
      // 1. Masukkan data ke box SEBELUM membuat controller
      final box = Hive.box<LogModel>('offline_logs');
      final existingLog = LogModel(
        id: 'old_id_123',
        title: 'Catatan Lama',
        description: 'Data dari sesi sebelumnya',
        date: '30-03-2026 09:00',
        authorId: 'nezya085',
        teamId: 'team_proyek4',
      );
      await box.put(existingLog.id, existingLog);

      // 2. Buat controller (ia akan otomatis panggil _refreshUI di constructor) 
      final controller = LogController();
      
      // Berikan jeda microtask agar notifier selesai diupdate [cite: 817]
      await Future.delayed(Duration.zero);

      // 3. Verifikasi data otomatis muncul [cite: 812, 821]
      expect(controller.logsNotifier.value.length, 1);
      expect(controller.logsNotifier.value.first.title, 'Catatan Lama');
    });
  });
}