import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart'; // Import tujuan berikutnya

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1; // Variabel langkah (Langkah 1 Modul) [cite: 109]

  void _nextStep() {
    setState(() {
      if (step < 3) {
        step++; // Tambah langkah [cite: 110]
      } else {
        // Jika sudah langkah 3, pindah ke Login dan hapus stack [cite: 110]
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Halaman Onboarding", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text("$step", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextStep,
              child: const Text("Lanjut"),
            ),
          ],
        ),
      ),
    );
  }
}