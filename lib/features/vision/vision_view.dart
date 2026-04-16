import 'package:flutter/material.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';
import 'package:camera/camera.dart';

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
    _visionController.dispose(); // Mencegah memory leak [cite: 249]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart-Patrol Vision"),
        backgroundColor: const Color(0xFF2F4156),
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildVisionStack();
        },
      ),
    );
  }

  Widget _buildVisionStack() {
    // LayoutBuilder memastikan kita mendapatkan ukuran layar yang valid [cite: 286]
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

            // LAYER 2: Overlay Deteksi (Task 4)
            Positioned.fill(
              child: CustomPaint(
                // Melewatkan koordinat mock agar bisa bergerak dinamis [cite: 309]
                painter: DamagePainter(
                  mockX: _visionController.mockX,
                  mockY: _visionController.mockY,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}