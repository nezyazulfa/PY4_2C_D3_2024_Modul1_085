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
        title: const Text("LogBook: Versi SRP & History"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // Agar layar bisa di-scroll jika history penuh
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text("Total Hitungan:"),
              Text('${_controller.value}', style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 20),

              // TASK 1: Input Step [cite: 208]
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

              // TASK 2: Menampilkan History [cite: 220]
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: _controller.history.map((log) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.label_important_outline),
                      title: Text(log),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () => setState(() => _controller.increment()), // Update UI real-time [cite: 223]
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () => setState(() => _controller.decrement()),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn3",
            backgroundColor: Colors.redAccent,
            onPressed: () => setState(() => _controller.reset()),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}