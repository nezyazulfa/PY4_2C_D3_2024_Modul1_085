import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart'; // Pastikan path ini benar

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedCategory = 'Pribadi';
  final List<String> _categories = ['Pribadi', 'Pekerjaan', 'Urgent'];

  // Palette Warna Nezya
  static const Color navyColor = Color(0xFF2F4156);
  static const Color tealColor = Color(0xFF567C8D);
  static const Color beigeColor = Color(0xFFF5EFEB);

  @override
  void initState() {
    super.initState();
    _initCloud();
  }

  // Koneksi awal ke MongoDB Atlas
  Future<void> _initCloud() async {
    setState(() => _isLoading = true);
    await MongoService().connect();
    await _controller.loadLogs(); // Panggil fungsi load dari Controller
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent': return Colors.red.withOpacity(0.1);
      case 'Pekerjaan': return Colors.blue.withOpacity(0.1);
      default: return Colors.green.withOpacity(0.1);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeColor,
        title: const Text("Logout", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin keluar dari Gatekeeper?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context) => const LoginView()), (r) => false),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI TAMBAH (FIX: Menggunakan toMap()) ---
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = 'Pribadi';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: beigeColor,
          title: const Text("Catatan Baru", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(hintText: "Judul")),
              TextField(controller: _contentController, decoration: const InputDecoration(hintText: "Deskripsi")),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDialogState(() => _selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: navyColor),
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  // Kirim data ke Controller (Controller yang akan panggil toMap)
                  await _controller.addLog(_titleController.text, _contentController.text, _selectedCategory);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Simpan ke Cloud", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI EDIT ---
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: beigeColor,
          title: const Text("Edit Catatan", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController),
              TextField(controller: _contentController),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDialogState(() => _selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tealColor),
              onPressed: () async {
                await _controller.updateLog(index, _titleController.text, _contentController.text, _selectedCategory);
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeColor,
      appBar: AppBar(
        title: const Text("Nezya's Logbook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: navyColor,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _showLogoutDialog)],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => _controller.filterLogs(val),
              decoration: InputDecoration(
                hintText: "Cari judul...",
                prefixIcon: const Icon(Icons.search, color: tealColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: tealColor)) // Loading state
            : ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.filteredLogsNotifier,
                builder: (context, currentLogs, child) {
                  if (currentLogs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, size: 80, color: tealColor),
                          SizedBox(height: 10),
                          Text("Data Tidak Ditemukan", style: TextStyle(color: tealColor)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];
                      return Card(
                        color: _getCategoryColor(log.category),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: navyColor, child: Icon(Icons.cloud_done, color: Colors.white, size: 20)),
                          title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, color: navyColor)),
                          subtitle: Text("${log.description}\n[${log.category}] - ${log.date.split(' ')[0]}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showEditLogDialog(index, log)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _controller.removeLog(index)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: navyColor,
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}