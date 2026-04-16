import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  setUpAll(() async {
    // 1. Load kredensial dari .env
    await dotenv.load(fileName: ".env");
  });

  group('MongoService Cloud Integration Tests', () {
    
    // TC-M4-01: Uji Koneksi Dasar
    test('TC-M4-01 - Should successfully connect to MongoDB Atlas', () async {
      final mongoService = MongoService();
      await mongoService.connect();
      
      expect(dotenv.env['MONGODB_URI'], isNotNull);
      
      await mongoService.close();
    });

    // TC-M4-02: Uji Simpan ke Cloud
    test('TC-M4-02 - Should insert a new log into Atlas collection', () async {
      final mongoService = MongoService();
      await mongoService.connect();

      // Buat data test dengan ID unik (Hex String)
      final String mockId = ObjectId().oid; 
      final testLog = LogModel(
        id: mockId,
        title: 'Test Cloud Nezya 085',
        description: 'Unit Test Berhasil',
        date: '31-03-2026 14:00',
        authorId: 'nezya085',
        teamId: 'team_proyek4',
        isPublic: true
      );

      // FIX: Tambahkan .toMap() agar tipe datanya sesuai Map<String, dynamic>
      await mongoService.insertLog(testLog.toMap());

      // Verifikasi: Cek apakah data benar-benar masuk ke Atlas
      final logs = await mongoService.getLogs('team_proyek4');
      final uploaded = logs.any((l) => l.id == mockId);
      
      expect(uploaded, true);
      await mongoService.close();
    });

    // TC-M4-03: Uji Update Dokumen di Cloud
    test('TC-M4-03 - Should update an existing log in Atlas', () async {
      final mongoService = MongoService();
      await mongoService.connect();

      // 1. Ambil data terakhir dari cloud
      final logs = await mongoService.getLogs('team_proyek4');
      if (logs.isNotEmpty) {
        final targetLog = logs.first;
        
        // 2. Modifikasi judul menggunakan copyWith
        final updatedLog = targetLog.copyWith(isPublic: false);
        
        // 3. Jalankan Update (Fungsi updateLog kamu sudah menerima objek LogModel)
        await mongoService.updateLog(updatedLog);

        // 4. Verifikasi perubahan
        final refreshedLogs = await mongoService.getLogs('team_proyek4');
        final check = refreshedLogs.firstWhere((l) => l.id == targetLog.id);
        expect(check.isPublic, false);
      }
      
      await mongoService.close();
    });

  });
}