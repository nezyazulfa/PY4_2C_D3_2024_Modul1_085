import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0; 
  
  int _step = 1; 
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;
  int get step => _step; 

  // PERBAIKAN TC03 & TC07: 
  // Menggunakan >= 0 agar angka 0 (untuk reset) diperbolehkan, 
  // tapi angka negatif tetap diabaikan.
  set step(int value) {
    if (value >= 0) { 
      _step = value;
    }
  }

  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('${username}_counter') ?? 0;
    
    // Memuat nilai step (menggunakan setter agar tervalidasi)
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
    await prefs.setInt('${username}_step', _step); 
    await prefs.setStringList('${username}_history', _history);
  }

  void increment(String username) {
    _counter += _step; 
    _addLog("User $username menambah +$_step");
    _saveToLocal(username);
  }

  void decrement(String username) {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addLog("User $username mengurangi -$_step");
    } else {
      _counter = 0; 
      _addLog("User $username mencoba mengurangi di bawah 0");
    }
    _saveToLocal(username);
  }

  // PERBAIKAN TC07:
  // Mengubah step menjadi 0 sesuai ekspektasi di dokumen Excel.
  void reset(String username) {
    _counter = 0;
    _step = 0; // Langsung ke 0 agar sesuai dengan TC07
    _history.clear();
    _addLog("User $username melakukan reset data");
    _saveToLocal(username);
  }

  void _addLog(String action) {
    String time = DateTime.now().toString().substring(11, 16);
    _history.insert(0, "$action pada jam $time");
    
    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}