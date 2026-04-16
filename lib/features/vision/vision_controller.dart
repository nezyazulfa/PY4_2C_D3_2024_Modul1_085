import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;

  // Variabel untuk Task 4 (Simulasi Koordinat AI YOLO)
  double mockX = 0.5; // Titik tengah (0.0 sampai 1.0)
  double mockY = 0.5; 
  Timer? _mockTimer;
  final Random _random = Random();

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false, 
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
      
      // MULAI SIMULASI MOCK DETECTOR (Task 4)
      _startMockDetection();

    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  // Fungsi mengubah koordinat setiap 3 detik secara dinamis
  void _startMockDetection() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Menghasilkan angka acak antara 0.2 hingga 0.8 agar kotak tidak terlalu ke pinggir
      mockX = 0.2 + _random.nextDouble() * 0.6; 
      mockY = 0.2 + _random.nextDouble() * 0.6;
      notifyListeners(); // Memaksa UI untuk menggambar ulang (Mencegah Flicker)
    });
  }

  // RESOURCE GUARD: Penanganan saat aplikasi masuk ke Background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Mematikan kamera dan timer saat aplikasi tidak terlihat
      _mockTimer?.cancel();
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera(); // Nyalakan ulang saat aplikasi dibuka kembali
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockTimer?.cancel(); // Mencegah memory leak dari timer
    controller?.dispose(); // Membunuh proses kamera sepenuhnya
    super.dispose();
  }
}