import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  // Data konten Onboarding (Gambar, Judul, dan Deskripsi)
  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/Gambar1.png",
      "title": "Catat Aktivitas",
      "desc": "Pantau semua kegiatan harianmu dengan mudah dan cepat."
    },
    {
      "image": "assets/Gambar2.png",
      "title": "Keamanan Terjamin",
      "desc": "Data logbook kamu tersimpan aman dengan sistem Gatekeeper."
    },
    {
      "image": "assets/Gambar3.png",
      "title": "Riwayat Tersimpan",
      "desc": "Jangan takut kehilangan data, aplikasi akan mengingat angka terakhirmu."
    },
  ];

  void _nextStep() {
    setState(() {
      if (step < 3) {
        step++; 
      } else {
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menampilkan Gambar sesuai langkah
              Image.asset(
                onboardingData[step - 1]["image"]!,
                height: 300,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.image, size: 200, color: Colors.grey),
              ),
              
              const SizedBox(height: 40),

              Text(
                onboardingData[step - 1]["title"]!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                onboardingData[step - 1]["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Page Indicator (Titik Indikator)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: step == index + 1 ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: step == index + 1 ? Colors.indigo : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(step == 3 ? "Mulai Sekarang" : "Lanjut"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}