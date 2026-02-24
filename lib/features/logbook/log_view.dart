import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart'; // Pastikan import ini benar untuk navigasi logout

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  
  // Controller untuk menangkap input teks di dialog [cite: 111]
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Definisi Warna Palette Nezya
  static const Color navyColor = Color(0xFF2F4156);
  static const Color tealColor = Color(0xFF567C8D);
  static const Color beigeColor = Color(0xFFF5EFEB);

  @override
  void dispose() {
    _titleController.dispose(); // [cite: 139]
    _contentController.dispose(); // [cite: 139]
    super.dispose();
  }

  // --- FUNGSI DIALOG LOGOUT ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeColor,
        title: const Text("Konfirmasi Logout", 
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Kembali ke halaman Login dan hapus semua tumpukan halaman
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI TAMBAH CATATAN [cite: 111] ---
  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeColor,
        title: const Text("Tambah Catatan Baru", 
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: navyColor),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.addLog(_titleController.text, _contentController.text); // [cite: 99, 111]
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI EDIT CATATAN [cite: 112, 119] ---
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeColor,
        title: const Text("Edit Catatan", 
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _contentController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tealColor),
            onPressed: () {
              _controller.updateLog(index, _titleController.text, _contentController.text); // [cite: 99, 112]
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI KONFIRMASI HAPUS ---
  void _showDeleteConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeColor,
        title: const Text("Hapus Catatan?", 
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
        content: const Text("Apakah kamu yakin ingin menghapus catatan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _controller.removeLog(index); // [cite: 99, 118]
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Catatan berhasil dihapus")),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeColor,
      appBar: AppBar(
        title: const Text("My Logbook", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: navyColor,
        centerTitle: true,
        // TOMBOL LOGOUT DI KANAN APPBAR
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      // Reactive UI menggunakan ValueListenableBuilder [cite: 101, 105]
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, currentLogs, child) {
          if (currentLogs.isEmpty) {
            return const Center(
              child: Text("Belum ada catatan logbook.", 
                style: TextStyle(color: tealColor, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: currentLogs.length, // [cite: 105]
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: tealColor,
                    child: Icon(Icons.notes, color: Colors.white),
                  ),
                  title: Text(log.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: navyColor)),
                  subtitle: Text(log.description),
                  // Langkah 5: Interaksi Edit dan Delete [cite: 115, 122]
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditLogDialog(index, log),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmDialog(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: navyColor,
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}