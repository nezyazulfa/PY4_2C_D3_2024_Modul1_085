import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1; // Variabel untuk custom step (Default 1)
  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // Update setter untuk step agar bisa diubah dari View
  set step(int value) => _step = value;

  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('${username}_counter') ?? 0;
    _step = prefs.getInt('${username}_step') ?? 1; // Load custom step juga
    
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
    await prefs.setInt('${username}_step', _step); // Simpan custom step
    await prefs.setStringList('${username}_history', _history);
  }

  // Fungsi Tambah (Increment)
  void increment(String username) {
    _counter += _step; // Gunakan variabel step
    _addLog("User $username menambah +$_step");
    _saveToLocal(username);
  }

  // --- FITUR BARU: Kurangi (Decrement) ---
  void decrement(String username) {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addLog("User $username mengurangi -$_step");
    } else {
      _counter = 0; // Agar tidak negatif
      _addLog("User $username mencoba mengurangi di bawah 0");
    }
    _saveToLocal(username);
  }

  // --- FITUR BARU: Reset ---
  void reset(String username) {
    _counter = 0;
    _step = 1; // Kembalikan step ke default
    _history.clear();
    _addLog("User $username melakukan reset data");
    _saveToLocal(username);
  }

  void _addLog(String action) {
    String time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "$action pada jam $time");
    if (_history.length > 5) _history.removeLast();
  }
}