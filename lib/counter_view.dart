import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController(); // Inisialisasi controller [cite: 170]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: SRP, History & UX"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // [cite: 113]
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text("Total Hitungan:"),
              Text('${_controller.value}', 
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 20),

              // UI Input Step (Task 1) [cite: 208]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Besar Langkah (Step)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bolt),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _controller.setStep(int.tryParse(value) ?? 1);
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const Text("5 Aktivitas Terakhir:", style: TextStyle(fontWeight: FontWeight.bold)),

              // UI Polishing: Warna berbeda untuk riwayat (Homework) 
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: _controller.history.map((log) {
                    // Hijau untuk Tambah, Merah untuk Kurang 
                    Color itemColor = log.contains("Tambah") ? Colors.green : 
                                      log.contains("Kurang") ? Colors.red : 
                                      Colors.blue;

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.history, color: itemColor),
                        title: Text(log, style: TextStyle(color: itemColor)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
      
      // Lokasi tombol di tengah bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // Susunan tombol ke samping (Row) yang rapat di tengah
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Kurang (-)
          FloatingActionButton(
            heroTag: "remove",
            backgroundColor: Colors.orange,
            onPressed: () => setState(() => _controller.decrement()),
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 20), // Jarak antar tombol

          // Tombol Tambah (+)
          FloatingActionButton(
            heroTag: "add",
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),

          const SizedBox(width: 20), // Jarak antar tombol

          // Tombol Reset dengan Dialog Konfirmasi (UX Improvement) 
          FloatingActionButton(
            heroTag: "reset",
            backgroundColor: Colors.redAccent,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Reset"),
                  content: const Text("Yakin ingin menghapus semua data?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _controller.reset());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data berhasil direset!")),
                        );
                      },
                      child: const Text("Ya, Reset", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}