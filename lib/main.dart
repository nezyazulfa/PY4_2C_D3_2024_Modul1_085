import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/logbook/models/log_model.dart';
import 'features/onboarding/onboarding_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // INISIALISASI HIVE
  await Hive.initFlutter(); 
  
  // REGISTER ADAPTER (Pastikan .g.dart sudah ada)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LogModelAdapter()); 
  }

  // BUKA BOX (Sesuai dengan nama di Controller)
  await Hive.openBox<LogModel>('offline_logs'); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F4156),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const OnboardingView(), 
    );
  }
}