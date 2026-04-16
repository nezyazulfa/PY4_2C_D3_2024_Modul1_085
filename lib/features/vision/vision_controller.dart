import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;
  bool isPermissionDenied = false;

  // Variabel Task 4 & Homework (Simulasi Koordinat & Tipe Kerusakan AI YOLO)
  double mockX = 0.5;
  double mockY = 0.5; 
  String mockDamageType = 'D40'; // Variabel Baru untuk Tipe Kerusakan
  
  Timer? _mockTimer;
  final Random _random = Random();

  bool isFlashOn = false;
  bool isOverlayVisible = true;

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<void> initCamera() async {
    isPermissionDenied = false;
    errorMessage = null;
    notifyListeners();

    try {
      var status = await Permission.camera.request();
      if (status.isPermanentlyDenied || status.isDenied) {
        isPermissionDenied = true;
        notifyListeners();
        return;
      }

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
      
      _startMockDetection();
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  void _startMockDetection() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      mockX = 0.2 + _random.nextDouble() * 0.6; 
      mockY = 0.2 + _random.nextDouble() * 0.6;
      
      // LOGIKA BARU: Mengacak tipe kerusakan 50:50 (D40 atau D00)
      mockDamageType = _random.nextBool() ? 'D40' : 'D00';
      
      notifyListeners(); 
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _mockTimer?.cancel();
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockTimer?.cancel(); 
    controller?.dispose(); 
    super.dispose();
  }

  Future<void> toggleFlash() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      isFlashOn = !isFlashOn;
      await controller!.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal menyalakan senter: $e");
    }
  }

  void toggleOverlay() {
    isOverlayVisible = !isOverlayVisible;
    notifyListeners();
  }
  
  Future<XFile?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    if (controller!.value.isTakingPicture) return null; 
    try {
      return await controller!.takePicture();
    } catch (e) {
      debugPrint("Gagal mengambil foto: $e");
      return null;
    }
  }
}