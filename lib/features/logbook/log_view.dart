import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart';
import 'log_editor_page.dart';

class LogView extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  bool _isLoading = false;

  static const Color navyColor = Color(0xFF2F4156);
  static const Color tealColor = Color(0xFF567C8D);
  static const Color bgGrey = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _initCloud();
  }

  Future<void> _initCloud() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await MongoService().connect(); 
      await _controller.loadLogs(widget.currentUser['teamId']);   
    } catch (e) {
      debugPrint("Koneksi Cloud Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LogEditorPage(
      log: log, index: index, controller: _controller, currentUser: widget.currentUser,
    )));
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent': return const Color(0xFFFFE5E5);
      case 'Pekerjaan': return const Color(0xFFE5F0FF);
      default: return const Color(0xFFE5FFED);
    }
  }

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
              await _controller.removeLog(index, widget.currentUser['role'], widget.currentUser['uid']);
              if (!context.mounted) return; 
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
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
          SliverAppBar(
            backgroundColor: navyColor,
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "${_getGreeting()}, ${widget.currentUser['username']}!",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              background: Container(color: navyColor),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.sync_rounded, color: Colors.white), onPressed: _initCloud, tooltip: "Refresh & Sinkron"),
              IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: _showLogoutDialog),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16.0), child: _buildSearchBar())),
          SliverFillRemaining(
            hasScrollBody: true,
            child: _isLoading ? const Center(child: CircularProgressIndicator(color: tealColor)) : _buildLogList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navyColor,
        onPressed: () => _goToEditor(),
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
        decoration: const InputDecoration(
          hintText: "Cari inspirasimu...",
          prefixIcon: Icon(Icons.search_rounded, color: tealColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    return ValueListenableBuilder<List<LogModel>>(
      valueListenable: _controller.filteredLogsNotifier,
      builder: (context, allLogs, child) {
        // --- TASK 5: FILTER VISIBILITAS ---
        final displayLogs = allLogs.where((log) {
          bool isOwner = log.authorId == widget.currentUser['uid'];
          return isOwner || log.isPublic; // Tampilkan JIKA milik sendiri ATAU Publik
        }).toList();

        if (displayLogs.isEmpty) return const Center(child: Text("Belum ada cerita hari ini..."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayLogs.length,
          itemBuilder: (context, index) {
            final log = displayLogs[index];
            final bool isOwner = log.authorId == widget.currentUser['uid'];

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
                  decoration: BoxDecoration(color: _getCategoryColor(log.category), borderRadius: BorderRadius.circular(12)),
                  // --- TASK 5: IKON PRIVASI ---
                  child: Icon(
                    log.isPublic ? Icons.public : Icons.lock_person, 
                    color: log.isSynced ? navyColor : Colors.orange,
                  ),
                ),
                title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(log.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- TASK 5: KEDAULATAN EDITOR (Hanya Owner) ---
                    if (isOwner)
                      IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20), onPressed: () => _goToEditor(log: log, index: index)),
                    if (isOwner)
                      IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => _showDeleteConfirmation(index, log.title)),
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