import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  // --- BAGIAN PENTING UNTUK DATA PERSISTENCE ---
  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Dipanggil satu kali saja saat halaman dibuka
  }

  // Hanya butuh SATU fungsi _loadInitialData
  void _loadInitialData() async {
    // Pastikan mengirim widget.username agar angka tiap user berbeda
    await _controller.loadData(widget.username); 
    if (mounted) {
      setState(() {}); 
    }
  }
  // --------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
                          // Navigasi logout dan bersihkan tumpukan halaman [cite: 128, 129]
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingView()),
                            (route) => false,
                          );
                        },
                        child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text("Selamat Datang, ${widget.username}!"),
            const SizedBox(height: 10),
            const Text("Total Hitungan Anda:"),
            Text(
              '${_controller.value}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Divider(height: 40, thickness: 2),
            const Text("Riwayat Aktivitas (Log):", style: TextStyle(fontWeight: FontWeight.bold)),
            
            // --- MENAMPILKAN HISTORY LOG (TASK 3) ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(_controller.history[index]), // Menampilkan isi riwayat [cite: 163]
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Panggil fungsi increment dan kirim nama user untuk dicatat [cite: 125]
        onPressed: () => setState(() => _controller.increment(widget.username)),
        child: const Icon(Icons.add),
      ),
    );
  }
}