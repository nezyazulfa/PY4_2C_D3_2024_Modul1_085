import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// PERBAIKAN: Menggunakan package import
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // Memastikan file .env dimuat sebelum test dijalankan
    await dotenv.load(fileName: ".env");
  });

  test('Memastikan koneksi ke MongoDB Atlas berhasil via MongoService', () async {
    // Inisialisasi MongoService (Singleton)
    final mongoService = MongoService();

    await LogHelper.writeLog("--- START CONNECTION TEST ---", source: sourceFile);

    try {
      // Mencoba koneksi ke Cluster Atlas
      await mongoService.connect();
      expect(dotenv.env['MONGODB_URI'], isNotNull);

      await LogHelper.writeLog(
        "SUCCESS: Koneksi Atlas Terverifikasi",
        source: sourceFile,
        level: 2, 
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Kegagalan koneksi - $e",
        source: sourceFile,
        level: 1, 
      );
      fail("Koneksi gagal: $e");
    } finally {
      // Menutup koneksi database
      await mongoService.close();
      await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
    }
  });
}