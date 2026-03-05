import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart';

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

  static const Color navyColor = Color(0xFF2F4156);
  static const Color tealColor = Color(0xFF567C8D);
  static const Color bgGrey = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _initCloud();
  }

  // --- FITUR: Salam Otomatis Berdasarkan Waktu ---
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  Future<void> _initCloud() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect(); 
      await _controller.loadLogs();   
    } catch (e) {
      debugPrint("Koneksi Cloud Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent': return const Color(0xFFFFE5E5);
      case 'Pekerjaan': return const Color(0xFFE5F0FF);
      default: return const Color(0xFFE5FFED);
    }
  }

  // --- FITUR: Konfirmasi Hapus ---
  void _showDeleteConfirmation(int index, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Catatan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah kamu yakin ingin menghapus '$title'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _controller.removeLog(index);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFormDialog({required String title, required bool isEdit, int? index}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: navyColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Judul",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => _selectedCategory = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  if (isEdit) {
                    await _controller.updateLog(index!, _titleController.text, _contentController.text, _selectedCategory);
                  } else {
                    await _controller.addLog(_titleController.text, _contentController.text, _selectedCategory);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin keluar?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: CustomScrollView(
        slivers: [
          // --- APP BAR DENGAN SALAM DINAMIS ---
          SliverAppBar(
            backgroundColor: navyColor,
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "${_getGreeting()}, Nezya!", // Update: Salam berdasarkan waktu
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(color: navyColor),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: _showLogoutDialog),
              const SizedBox(width: 8),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
          ),
          
          SliverFillRemaining(
            hasScrollBody: true,
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: tealColor)) 
            : _buildLogList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navyColor,
        onPressed: () => _showFormDialog(title: "Buat Catatan Baru", isEdit: false),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("New Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: (val) => _controller.filterLogs(val),
        decoration: InputDecoration(
          hintText: "Cari inspirasimu...",
          prefixIcon: const Icon(Icons.search_rounded, color: tealColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    return ValueListenableBuilder<List<LogModel>>(
      valueListenable: _controller.filteredLogsNotifier,
      builder: (context, currentLogs, child) {
        if (currentLogs.isEmpty) {
          return const Center(child: Text("Belum ada cerita hari ini..."));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: currentLogs.length,
          itemBuilder: (context, index) {
            final log = currentLogs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(log.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: navyColor),
                ),
                title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(log.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                      onPressed: () => _showFormDialog(title: "Edit Catatan", isEdit: true, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () => _showDeleteConfirmation(index, log.title), // Update: Pakai konfirmasi
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}