import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")), // [cite: 174]
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // [cite: 177]
          children: [
            const Text("Total Hitungan:"), // [cite: 179]
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)), // [cite: 180]
            
            const SizedBox(height: 30), // Memberi jarak antar widget

            // --- TASK 1: Tambahkan TextField untuk input Step ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                keyboardType: TextInputType.number, // Memastikan keyboard yang muncul adalah angka
                decoration: const InputDecoration(
                  labelText: "Besar Langkah (Step)",
                  hintText: "Contoh: 5",
                  border: OutlineInputBorder(), // Membuat kotak di sekeliling input
                ),
                onChanged: (value) {
                  // Mengubah String input menjadi Integer [cite: 206]
                  int inputStep = int.tryParse(value) ?? 1;
                  // Mengirim nilai ke Controller [cite: 206]
                  _controller.setStep(inputStep);
                },
              ),
            ),
          ],
        ),
      ),
      // Menambahkan tombol tambah dan kurang agar terlihat efek step-nya
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()), // [cite: 185]
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()), // Menguji fungsi decrement [cite: 207]
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}