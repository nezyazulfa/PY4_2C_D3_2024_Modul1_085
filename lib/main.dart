import 'package:flutter/material.dart';
import 'counter_view.dart'; // Menghubungkan ke file wajah (View) baru Anda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false, // Menghilangkan pita debug merah
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Di sini kuncinya: Ganti MyHomePage dengan CounterView
      home: const CounterView(), 
    );
  }
}