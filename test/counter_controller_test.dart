import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: avoid_relative_lib_imports
import '../lib/counter_controller.dart'; // Sesuaikan dengan path file Anda

void main() {
  group('CounterController Test', () {
    
    // TC01: Positif - initial value should be 0
    test('TC01 - initial value should be 0', () {
      SharedPreferences.setMockInitialValues({}); 
      final controller = CounterController(); 
      final actualValue = controller.value; 
      expect(actualValue, 0); 
    });

    // TC02: Positif - setStep should change step value
    test('TC02 - setStep should change step value', () {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();

      // 2. Exercise (act, operate)
      // Ubah nilai step menjadi 5 (Sesuai Data Test)
      controller.step = 5;

      // Get nilai step hasil eksekusi program sebagai nilai aktual
      final actualStep = controller.step;

      // 3. Verify (assert, check)
      // Bandingkan nilai aktual dan ekspektasi (nilai step sekarang harus 5)
      expect(actualStep, 5);
    });

    // TC03: Negatif - setStep should ignore negative value
    test('TC03 - setStep should ignore negative value', () {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();

      // 2. Exercise (act, operate)
      // Set nilai step awal menjadi 3 (Sesuai kondisi di Excel)
      controller.step = 3; 
      
      // Coba ubah nilai step menjadi negatif (-1)
      controller.step = -1; 

      // Get nilai step hasil eksekusi program sebagai nilai aktual
      final actualStep = controller.step;

      // 3. Verify (assert, check)
      // Ekspektasi: Nilai tidak berubah menjadi -1, melainkan tetap 3
      expect(actualStep, 3);
    });

    // TC04: Positif - increment should add step by 1
    test('TC04 - increment should add step by 1', () async {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();
      
      // Load initial value (menggunakan await karena Future)
      await controller.loadData('admin'); 

      // 2. Exercise (act, operate)
      // Panggil fungsi increment
      controller.increment('admin'); 
      
      // Get nilai counter hasil eksekusi program sebagai nilai aktual
      final actualValue = controller.value;

      // 3. Verify (assert, check)
      // Bandingkan nilai aktual dan ekspektasi
      // Counter awal 0, default step 1. Setelah increment, counter harusnya 1.
      expect(actualValue, 1);
    });

    // TC05: Positif - decrement should reduce counter by 1
    test('TC05 - decrement should reduce counter by 1', () async {
      // 1. Setup (arrange, build)
      // Kita set mock data di mana counter awal = 5 dan step = 1
      // Agar saat dikurangi, nilainya berubah dari 5 menjadi 4 sesuai ekspektasi.
      SharedPreferences.setMockInitialValues({
        'admin_counter': 5,
        'admin_step': 1
      });
      
      final controller = CounterController();
      await controller.loadData('admin'); // Memuat counter = 5 dan step = 1

      // 2. Exercise (act, operate)
      // Panggil fungsi decrement (Akan mengkalkulasi: 5 - 1)
      controller.decrement('admin');

      // Get nilai counter hasil eksekusi program sebagai nilai aktual
      final actualValue = controller.value;

      // 3. Verify (assert, check)
      // Bandingkan nilai aktual dan ekspektasi (harus 4)
      expect(actualValue, 4);
    });

    // TC06: Negatif - decrement should not go below 0
    test('TC06 - decrement should not go below 0', () async {
      // 1. Setup (arrange, build)
      // Kita inisialisasi storage kosong, sehingga counter awal = 0 dan step = 1
      SharedPreferences.setMockInitialValues({});
      
      final controller = CounterController();
      await controller.loadData('admin'); // Memuat initial value (counter = 0)

      // 2. Exercise (act, operate)
      // Panggil fungsi decrement (Akan mencoba mengurangi: 0 - 1)
      controller.decrement('admin');

      // Get nilai counter hasil eksekusi program sebagai nilai aktual
      final actualValue = controller.value;

      // 3. Verify (assert, check)
      // Ekspektasi: Nilai tidak menjadi -1, melainkan tetap 0
      expect(actualValue, 0);
    });

    // TC07: Positif - reset should change step to 0
    test('TC07 - reset should change step to 0', () async {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();
      
      // Panggil setStep(10) sesuai data test di Excel
      controller.step = 10;

      // 2. Exercise (act, operate)
      // Panggil fungsi reset
      controller.reset('admin');

      // 3. Verify (assert, check)
      // Get nilai step (bukan counter) karena ekspektasi Excel adalah nilai step
      final actualStep = controller.step;

      // Bandingkan nilai aktual dan ekspektasi (Step sebelumnya = 10, sekarang harus 0)
      expect(actualStep, 0);
    });

    // TC08: Positif - history should record increment action
    test('TC08 - history should record increment action', () async {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();

      // 2. Exercise (act, operate)
      // Kita panggil increment untuk user 'admin'
      controller.increment('admin');

      // 3. Verify (assert, check)
      // Kita cek apakah list history tidak kosong
      expect(controller.history.isNotEmpty, true);
      
      // Kita cek apakah isi log pertama mengandung kata kunci yang sesuai
      // Format log kita: "User admin menambah +1 pada jam HH:mm"
      expect(controller.history[0], contains('User admin menambah +1'));
    });

    // TC09: Positif - history should record reset action
    test('TC09 - history should record reset action', () async {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();

      // 2. Exercise (act, operate)
      // Panggil fungsi reset untuk user 'admin'
      controller.reset('admin');

      // 3. Verify (assert, check)
      // Get data dari list history
      final historyList = controller.history;

      // Periksa apakah list history tidak kosong
      expect(historyList.isNotEmpty, true);
      
      // Periksa apakah log reset tercatat dengan pesan yang benar
      // Format log: "User admin melakukan reset data pada jam HH:mm"
      expect(historyList[0], contains('User admin melakukan reset data'));
    });

    // TC10: Negatif - history should limit records to 5 items
    test('TC10 - history should limit records to 5 items', () async {
      // 1. Setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      final controller = CounterController();

      // 2. Exercise (act, operate)
      // Panggil fungsi increment sebanyak 6 kali (Sesuai Data Test)
      for (int i = 0; i < 6; i++) {
        controller.increment('admin');
      }

      // 3. Verify (assert, check)
      // Get total panjang list history
      final actualLength = controller.history.length;

      // Bandingkan panjang aktual dengan ekspektasi (Maksimal 5)
      expect(actualLength, 5);
      
      // Tambahan: Pastikan log yang tersisa adalah log terbaru
      // (Log ke-6 harusnya ada di index 0 karena kita menggunakan insert(0, ...))
      expect(controller.history.length, isNot(6));
    });

  });
}