import 'package:flutter/material.dart';
import '../logbook/log_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Palette Warna Nezya
    const Color navyColor = Color(0xFF2F4156);
    const Color beigeColor = Color(0xFFF5EFEB);

    return Scaffold(
      backgroundColor: beigeColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 80, color: navyColor),
              const SizedBox(height: 20),
              const Text(
                "Login Gatekeeper", // [cite: 134]
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: navyColor),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    // Masuk ke halaman Logbook (Modul 3)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LogView()),
                    );
                  },
                  child: const Text("Masuk", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}