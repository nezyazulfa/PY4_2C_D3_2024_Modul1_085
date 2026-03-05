import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart'; //
import 'features/onboarding/onboarding_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); //
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Logbook Nezya',
      theme: ThemeData(
        useMaterial3: true, // WAJIB untuk UI modern
        colorSchemeSeed: const Color(0xFF2F4156), // Warna Navy kebanggaan
        textTheme: GoogleFonts.poppinsTextTheme(), // Pakai font Gen Z
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Background bersih
      ),
      home: const OnboardingView(), //
    );
  }
}