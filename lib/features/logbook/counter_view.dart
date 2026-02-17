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

  // --- LOGIKA WELCOME BANNER (Homework Poin 3) ---
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData(); 
  }

  void _loadInitialData() async {
    // Memuat data sesuai username agar angka antar akun berbeda
    await _controller.loadData(widget.username); 
    if (mounted) {
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari Palette Nezya
    const Color navyColor = Color(0xFF2F4156);
    const Color tealColor = Color(0xFF567C8D);
    const Color beigeColor = Color(0xFFF5EFEB);

    return Scaffold(
      backgroundColor: beigeColor,
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: tealColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
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
            Text("${_getGreeting()}, ${widget.username}!", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navyColor)),
            const Text("Sekarang saya sedang mengerjakan proyek 4"),
            const SizedBox(height: 20),

            // --- Tampilan Angka Counter ---
            Text('${_controller.value}', 
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: navyColor)),
            
            const SizedBox(height: 10),

            // --- Pengaturan Custom Step (Slider) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text("Besar Langkah (Step): ${_controller.step}"),
                  Slider(
                    value: _controller.step.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: tealColor,
                    onChanged: (value) {
                      setState(() {
                        _controller.step = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- Tombol Utama: Kurang, Reset, Tambah ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Kurang (Decrement)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], foregroundColor: Colors.white),
                  onPressed: () => setState(() => _controller.decrement(widget.username)),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 15),
                // Tombol Reset
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
                  onPressed: () => setState(() => _controller.reset(widget.username)),
                  child: const Text("Reset"),
                ),
                const SizedBox(width: 15),
                // Tombol Tambah (Increment)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: navyColor, foregroundColor: Colors.white),
                  onPressed: () => setState(() => _controller.increment(widget.username)),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const Divider(height: 40, thickness: 2, indent: 50, endIndent: 50),
            const Text("Riwayat Aktivitas (Log):", style: TextStyle(fontWeight: FontWeight.bold, color: navyColor)),
            
            // --- ListView History Log ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: tealColor),
                      title: Text(_controller.history[index], style: const TextStyle(fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}