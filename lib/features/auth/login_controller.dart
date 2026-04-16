import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final Map<String, String> _users = {
    "admin": "123",
    "nezya": "zulfa",
    "budi": "ganteng",
  };

  int _failedAttempts = 0;
  bool _isLocked = false;

  int get failedAttempts => _failedAttempts;
  bool get isLocked => _isLocked;

  // Ubah menjadi Future<bool> karena ada proses simpan ke storage
  Future<bool> login(String username, String password) async {
    if (_users.containsKey(username) && _users[username] == password) {
      _failedAttempts = 0;
      
      // SIMPAN STATUS LOGIN KE STORAGE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      
      return true;
    }
    _failedAttempts++;
    return false;
  }

  Future<void> lockAccount() async {
    _isLocked = true;
    await Future.delayed(const Duration(seconds: 10));
    _isLocked = false;
    _failedAttempts = 0;
  }

  // Lengkapi fungsi logout agar menghapus status login
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
  }
}