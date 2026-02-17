class CounterController {
  int _counter = 0;
  int _step = 1; // Variabel _step default 1 [cite: 206]
  final List<String> _history = []; // List untuk menyimpan riwayat [cite: 218]

  int get value => _counter; // Getter akses data [cite: 155]
  List<String> get history => _history; // Akses list riwayat [cite: 219]

  void setStep(int newValue) {
    _step = newValue; // Fungsi mengubah nilai _step [cite: 206]
  }

  void _addLog(String action) {
    // Mengambil waktu saat ini untuk log yang informatif [cite: 219, 267]
    String time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "$action (Step: $_step) pada $time"); // Data baru di posisi atas [cite: 267]
    
    // Membatasi hanya 5 aktivitas terakhir [cite: 221, 267]
    if (_history.length > 5) {
      _history.removeLast(); // Menghapus data tertua [cite: 267]
    }
  }

  void increment() {
    _counter += _step; // Logika tambah menggunakan _step [cite: 207]
    _addLog("Tambah +");
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step; // Logika kurang menggunakan _step [cite: 207]
      _addLog("Kurang -");
    } else {
      _counter = 0;
      _addLog("Reset Otomatis (Batas 0)");
    }
  }

  void reset() {
    _counter = 0; // Mengembalikan nilai ke 0 [cite: 158]
    _addLog("Reset Total");
  }
}