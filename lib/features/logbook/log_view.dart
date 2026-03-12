import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../auth/login_view.dart';
import '../../services/mongo_service.dart';
import '../../services/access_control_service.dart'; 
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  // --- UPDATE: CATEGORIZATION & COLOR CODING ---
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical':
        return const Color(0xFFE5FFED); // Hijau (Sesuai tugas)
      case 'Electronic':
        return const Color(0xFFE5F0FF); // Biru (Sesuai tugas)
      case 'Software':
        return const Color(0xFFFFF7E5); // Amber/Oranye (Warna baru)
      default:
        return const Color(0xFFF1F3F5); // Grey untuk lainnya
    }
  }

  Color _getIconColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green;
      case 'Electronic': return Colors.blue;
      case 'Software': return Colors.orange;
      default: return tealColor;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah kamu yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginView()), 
                (route) => false,
              );
            }, 
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(LogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Catatan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah kamu yakin ingin menghapus '${log.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _controller.removeLog(log, widget.currentUser['role'], widget.currentUser['uid']);
              if (!context.mounted) return; 
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
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
                "Logbook ${widget.currentUser['username']}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              background: Container(color: navyColor),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white), 
                onPressed: _initCloud,
                tooltip: "Sinkronisasi",
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white), 
                onPressed: _showLogoutDialog,
                tooltip: "Logout",
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
          ),
          
          _isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: tealColor)))
            : _buildSliverLogList(),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tealColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 80,
              color: tealColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum ada aktivitas hari ini?",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: navyColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Mulai catat kemajuan proyek Anda dan bagikan inspirasi kepada tim!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _goToEditor(),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Buat Catatan Pertama"),
            style: ElevatedButton.styleFrom(
              backgroundColor: navyColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverLogList() {
    return ValueListenableBuilder<List<LogModel>>(
      valueListenable: _controller.filteredLogsNotifier,
      builder: (context, allLogs, child) {
        final displayLogs = allLogs.where((log) {
          bool isOwner = log.authorId == widget.currentUser['uid'];
          return isOwner || log.isPublic; 
        }).toList();

        if (displayLogs.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
                    // --- INTEGRASI WARNA KATEGORI ---
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(log.category), 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        log.isPublic ? Icons.public : Icons.lock_person, 
                        color: _getIconColor(log.category),
                      ),
                    ),
                    title: Text(
                      log.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.description, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Chip kecil untuk menunjukkan nama kategori secara teks
                        Text(
                          log.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getIconColor(log.category),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (AccessControlService.canPerform(widget.currentUser['role'], 'update', isOwner: isOwner))
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                            onPressed: () => _goToEditor(log: log, index: index),
                          ),
                        if (AccessControlService.canPerform(widget.currentUser['role'], 'delete', isOwner: isOwner))
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _showDeleteConfirmation(log),
                          ),
                      ],
                    ),
                  ),
                );
              },
              childCount: displayLogs.length,
            ),
          ),
        );
      },
    );
  }
}