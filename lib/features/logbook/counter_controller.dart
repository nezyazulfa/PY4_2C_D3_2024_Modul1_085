import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  // Memperbaiki peringatan "unnecessary_getters_setters"
  // Variabel dijadikan publik (tanpa _) agar bisa diakses langsung oleh Slider di View
  int step = 1; 
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('${username}_counter') ?? 0;
    // Memuat nilai step yang tersimpan
    step = prefs.getInt('${username}_step') ?? 1; 
    
    List<String>? savedHistory = prefs.getStringList('${username}_history');
    if (savedHistory != null) {
      _history.clear();
      _history.addAll(savedHistory);
    } else {
      _history.clear();
    }
  }

  Future<void> _saveToLocal(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_counter', _counter);
    // Menyimpan nilai step terbaru ke memori HP [cite: 185]
    await prefs.setInt('${username}_step', step); 
    await prefs.setStringList('${username}_history', _history);
  }

  void increment(String username) {
    _counter += step; 
    _addLog("User $username menambah +$step");
    _saveToLocal(username);
  }

  void decrement(String username) {
    if (_counter - step >= 0) {
      _counter -= step;
      _addLog("User $username mengurangi -$step");
    } else {
      _counter = 0; 
      _addLog("User $username mencoba mengurangi di bawah 0");
    }
    _saveToLocal(username);
  }

  void reset(String username) {
    _counter = 0;
    step = 1; 
    _history.clear();
    _addLog("User $username melakukan reset data");
    _saveToLocal(username);
  }

  void _addLog(String action) {
    // Mengambil jam dan menit saat ini [cite: 246]
    String time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "$action pada jam $time");
    // Membatasi riwayat agar tetap rapi (maksimal 5 data) [cite: 246]
    if (_history.length > 5) _history.removeLast();
  }
}