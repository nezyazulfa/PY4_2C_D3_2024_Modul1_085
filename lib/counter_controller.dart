class CounterController {
  // 1. Variabel private untuk menyimpan angka hitungan [cite: 154]
  int _counter = 0; 

  // 1. Variabel private untuk menyimpan nilai langkah (Step) 
  // Default diatur ke 1 sesuai spesifikasi Tugas 1.1 
  int _step = 1; 

  // Getter: Memberikan akses ke View untuk membaca nilai tanpa mengubahnya langsung [cite: 155]
  int get value => _counter;
  int get step => _step;

  // Tugas 1.1: Fungsi untuk mengubah nilai _step 
  // Fungsi ini akan dipanggil oleh onChanged pada TextField di View
  void setStep(int newValue) {
    _step = newValue;
  }

  // Tugas 1.2: Modifikasi logika agar menggunakan nilai _step [cite: 207]
  void increment() {
    _counter += _step; // Menambah sesuai nilai step yang diinput [cite: 207]
  }

  // Tugas 1.2: Logika pengurangan menggunakan nilai _step [cite: 207]
  void decrement() {
    // Validasi agar nilai tidak menjadi negatif (Opsional namun disarankan)
    if (_counter >= _step) {
      _counter -= _step;
    } else {
      _counter = 0; 
    }
  }

  // Fungsi tambahan untuk mereset hitungan [cite: 158]
  void reset() {
    _counter = 0;
  }
}