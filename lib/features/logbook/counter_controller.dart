import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  // 1. Load Data Berdasarkan Username
  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Key sekarang unik: username + _counter (Contoh: admin_counter)
    _counter = prefs.getInt('${username}_counter') ?? 0;
    
    // Key riwayat juga unik: username + _history
    List<String>? savedHistory = prefs.getStringList('${username}_history');
    if (savedHistory != null) {
      _history.clear();
      _history.addAll(savedHistory);
    } else {
      _history.clear(); // Bersihkan jika user baru belum punya riwayat
    }
  }

  // 2. Save Data Berdasarkan Username
  Future<void> _saveToLocal(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_counter', _counter);
    await prefs.setStringList('${username}_history', _history);
  }

  void increment(String username) {
    _counter++;
    _addLog("User $username menambah +1");
    _saveToLocal(username); // Simpan ke laci milik user ini
  }

  void _addLog(String action) {
    String time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "$action pada jam $time");
    if (_history.length > 5) _history.removeLast();
  }
}