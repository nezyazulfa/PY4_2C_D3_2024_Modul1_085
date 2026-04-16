import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Pastikan path ini sudah benar sesuai project kamu
import 'package:logbook_app_001/features/auth/login_controller.dart'; 

void main() {
  group('LoginController (Authentication) Tests', () {
    
    // TC-A01: Positif - Login Berhasil
    test('TC-A01 - Login should succeed with correct credentials', () async {
      // 1. Setup
      SharedPreferences.setMockInitialValues({});
      final controller = LoginController();

      // 2. Exercise
      // Gunakan password '123' sesuai database di controller
      // Tambahkan 'await' karena fungsi login sekarang asynchronous
      bool result = await controller.login('admin', '123');

      // 3. Verify
      expect(result, true); // Sekarang ini akan bernilai True
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), true); // Ini juga akan Pass
    });

    // TC-A02: Negatif - Login Gagal (Password Salah)
    test('TC-A02 - Login should fail with wrong password', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = LoginController();

      // Mencoba login dengan password yang salah
      bool result = await controller.login('admin', 'salah_password');

      expect(result, false);
    });

    // TC-A03: Positif - Logout Berhasil
    test('TC-A03 - Logout should clear login session', () async {
      // 1. Setup (Arrange): Kondisikan user seolah-olah sudah login di mock storage
      SharedPreferences.setMockInitialValues({'isLoggedIn': true});
      final controller = LoginController();

      // 2. Exercise (Act): Jalankan fungsi logout
      await controller.logout();

      // 3. Verify (Assert): Cek apakah status di storage sudah terhapus
      final prefs = await SharedPreferences.getInstance();
      
      // Kita pastikan nilainya bukan true lagi (setelah di-remove biasanya bernilai null)
      expect(prefs.getBool('isLoggedIn'), isNot(true));
    });

  });
}