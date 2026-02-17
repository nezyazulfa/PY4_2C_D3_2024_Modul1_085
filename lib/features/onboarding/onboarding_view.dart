import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/Gambar1.png",
      "title": "Halo!",
      "desc": "Saya Nezya Zulfa Fauziah dengan NIM 241511085."
    },
    {
      "image": "assets/Gambar2.png",
      "title": "Kelas 2C",
      "desc": "Saya dari kelas 2C Prodi D3 Teknik Informatika, Jurusan Teknik Komputer dan Informatika."
    },
    {
      "image": "assets/Gambar3.png",
      "title": "Selamat Datang di Proyek 4",
      "desc": "Sekarang saya sedang mengerjakan Proyek 4."
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Palette Warna dari Gambar
    const Color navyColor = Color(0xFF2F4156);
    const Color tealColor = Color(0xFF567C8D);
    const Color beigeColor = Color(0xFFF5EFEB);
    const Color skyBlueColor = Color(0xFFC8D9E6);

    return Scaffold(
      backgroundColor: beigeColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visual Onboarding
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  onboardingData[step - 1]["image"]!,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.person, size: 200, color: navyColor),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                onboardingData[step - 1]["title"]!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navyColor),
              ),
              const SizedBox(height: 10),
              Text(
                onboardingData[step - 1]["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: tealColor),
              ),
              const SizedBox(height: 40),

              // 2. Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: step == index + 1 ? 15 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: step == index + 1 ? skyBlueColor : Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Tombol Navigasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
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
                  },
                  child: Text(step == 3 ? "Mulai Proyek" : "Lanjut"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}