import 'package:flutter/material.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart-Patrol Vision",
          style: TextStyle(fontWeight: FontWeight.bold), // Tambah bold biar makin tegas
        ),
        backgroundColor: const Color(0xFF2F4156),
        foregroundColor: Colors.white, // BARIS INI: Mengubah teks dan tombol back jadi putih
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          // STATE 1: Izin Kamera Ditolak
          if (_visionController.isPermissionDenied) {
            return _buildPermissionError();
          }
          
          // STATE 2: Sedang Loading / Inisialisasi
          if (!_visionController.isInitialized && _visionController.errorMessage == null) {
            return _buildLoadingState();
          }

          // STATE 3: Error Hardware Lainnya
          if (_visionController.errorMessage != null) {
            return Center(child: Text(_visionController.errorMessage!));
          }

          // STATE 4: Berhasil (Tampilkan Kamera)
          return _buildVisionStack();
        },
      ),
    );
  }

  // ==========================================
  // WIDGET BARU: Feedback UI States
  // ==========================================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2F4156),
            strokeWidth: 5,
          ),
          const SizedBox(height: 20),
          Text(
            "Menghubungkan ke Sensor Visual...",
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionError() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              "No Camera Access",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Aplikasi memerlukan izin kamera untuk mendeteksi kerusakan jalan. Silakan aktifkan di pengaturan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _visionController.openSettings(),
              icon: const Icon(Icons.settings),
              label: const Text("Open Settings"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4156),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LAYER TAMPILAN UTAMA
  // ==========================================
  Widget _buildVisionStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1: Kamera (Full Screen)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _visionController.controller!.value.previewSize!.height,
                  height: _visionController.controller!.value.previewSize!.width,
                  child: CameraPreview(_visionController.controller!),
                ),
              ),
            ),

            // LAYER 2: Overlay Deteksi
            // LAYER 2: Overlay Deteksi
            if (_visionController.isOverlayVisible)
              Positioned.fill(
                child: CustomPaint(
                  painter: DamagePainter(
                    mockX: _visionController.mockX,
                    mockY: _visionController.mockY,
                    damageType: _visionController.mockDamageType, // BARIS BARU
                  ),
                ),
              ),

            // LAYER 3: Tombol Capture
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: () async {
                    final file = await _visionController.takePhoto();
                    if (file != null && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Hasil Tangkapan"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(File(file.path)),
                              ),
                              const SizedBox(height: 10),
                              Text("Lokasi: ${file.path.split('/').last}"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      width: 65, height: 65,
                      decoration: const BoxDecoration(
                        color: Colors.white70, shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // LAYER 4: Kontrol Hardware & UI
            Positioned(
              top: 40,
              right: 20,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        _visionController.isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _visionController.isFlashOn ? Colors.yellow : Colors.white,
                      ),
                      onPressed: () => _visionController.toggleFlash(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        _visionController.isOverlayVisible ? Icons.visibility : Icons.visibility_off,
                        color: _visionController.isOverlayVisible ? Colors.tealAccent : Colors.white,
                      ),
                      onPressed: () => _visionController.toggleOverlay(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}