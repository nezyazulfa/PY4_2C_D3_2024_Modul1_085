class CounterController {
  int _counter = 0;
  int _step = 1; // Default step adalah 1 [cite: 206]
  final List<String> _history = []; // List untuk menampung riwayat [cite: 218, 219]

  // Getter agar View bisa membaca data [cite: 155]
  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // Mengubah nilai step dari input View [cite: 206]
  void setStep(int newValue) {
    _step = newValue;
  }

  // Fungsi internal untuk mencatat aktivitas [cite: 219]
  void _addLog(String action) {
    String time = DateTime.now().toString().substring(11, 16); // Format jam:menit
    _history.insert(0, "$action (Step: $_step) pada $time"); // Tambah ke index teratas [cite: 267]
    
    // THE TWIST: Batasi hanya 5 aktivitas terakhir 
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  void increment() {
    _counter += _step; // Tambah berdasarkan step [cite: 207]
    _addLog("Tambah +");
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step; // Kurang berdasarkan step [cite: 207]
      _addLog("Kurang -");
    } else {
      _counter = 0;
      _addLog("Reset ke 0 (Batas Bawah)");
    }
  }

  void reset() {
    _counter = 0;
    _addLog("Reset Total");
  }
}