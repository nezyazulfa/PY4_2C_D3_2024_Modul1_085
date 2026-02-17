class LoginController {
  // 1. Database Multiple Users menggunakan Map<String, String> [cite: 147]
  final Map<String, String> _users = {
    "admin": "123",
    "nezya": "zulfa",
    "budi": "ganteng",
  };

  int _failedAttempts = 0; // Mencatat jumlah salah login 
  bool _isLocked = false; // Status apakah tombol dikunci 

  int get failedAttempts => _failedAttempts;
  bool get isLocked => _isLocked;

  // Fungsi pengecekan login [cite: 117]
  bool login(String username, String password) {
    if (_users.containsKey(username) && _users[username] == password) {
      _failedAttempts = 0; // Reset jika berhasil
      return true;
    }
    _failedAttempts++; // Tambah hitungan salah 
    return false;
  }

  // Logika mengunci tombol selama 10 detik 
  Future<void> lockAccount() async {
    _isLocked = true;
    await Future.delayed(const Duration(seconds: 10)); // Tunggu 10 detik 
    _isLocked = false;
    _failedAttempts = 0; // Reset setelah masa tunggu selesai
  }
}