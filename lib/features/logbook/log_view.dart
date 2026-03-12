import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

  void _viewLogDetails(LogModel log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogDetailsPage(
          log: log, 
          categoryColor: _getCategoryColor(log.category),
          iconColor: _getIconColor(log.category),
        ),
      ),
    );
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical': return const Color(0xFFE5FFED);
      case 'Electronic': return const Color(0xFFE5F0FF);
      case 'Software': return const Color(0xFFFFF7E5);
      default: return const Color(0xFFF1F3F5);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (r) => false);
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
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Logbook ${widget.currentUser['username']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              background: Container(color: navyColor),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.sync_rounded, color: Colors.white), onPressed: _initCloud),
              IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: _showLogoutDialog),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(16.0), child: _buildSearchBar()),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: (val) => _controller.filterLogs(val),
        decoration: const InputDecoration(hintText: "Cari inspirasimu...", prefixIcon: Icon(Icons.search_rounded, color: tealColor), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_rounded, size: 80, color: tealColor),
          const SizedBox(height: 16),
          Text("Belum ada catatan...", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
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

        if (displayLogs.isEmpty) return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState());

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = displayLogs[index];
                final bool isOwner = log.authorId == widget.currentUser['uid'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => _viewLogDetails(log), 
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _getCategoryColor(log.category), borderRadius: BorderRadius.circular(12)),
                      child: Icon(log.isPublic ? Icons.public : Icons.lock_person, color: _getIconColor(log.category)),
                    ),
                    title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(log.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: isOwner ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20), onPressed: () => _goToEditor(log: log, index: index)),
                        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => _showDeleteConfirmation(log)),
                      ],
                    ) : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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

// --- REVISI FINAL: HALAMAN DETAIL (ULTRA CLEAN & AESTHETIC) ---
class LogDetailsPage extends StatelessWidget {
  final LogModel log;
  final Color categoryColor;
  final Color iconColor;

  const LogDetailsPage({
    super.key, 
    required this.log, 
    required this.categoryColor, 
    required this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Modern dengan Ikon Besar
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF2F4156),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF2F4156), iconColor.withValues(alpha: 0.6)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    log.isPublic ? Icons.public_rounded : Icons.lock_rounded, 
                    size: 100, 
                    color: Colors.white.withValues(alpha: 0.15)
                  ),
                ),
              ),
            ),
          ),

          // Konten Informasi dalam List yang rapi
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPill(log.category, categoryColor, iconColor),
                        _buildPill(log.isPublic ? "Shared" : "Private", Colors.grey.shade100, Colors.grey.shade600),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      log.title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2F4156),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Metadata Horizontal
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: iconColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person_outline_rounded, size: 14, color: iconColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Author ID: ${log.authorId.substring(0, 5)}...",
                          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          log.date,
                          style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Divider(color: Color(0xFFF1F3F5), thickness: 1.5),
                    ),

                    // Markdown Content (Isi Utama)
                    MarkdownBody(
                      data: log.description,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(
                          fontSize: 16, 
                          height: 1.8, 
                          color: const Color(0xFF4A4A4A),
                        ),
                        h1: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 26, color: const Color(0xFF2F4156)),
                        h2: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF2F4156)),
                        listBullet: GoogleFonts.poppins(color: iconColor, fontWeight: FontWeight.bold),
                        blockquote: GoogleFonts.poppins(color: Colors.blueGrey, fontStyle: FontStyle.italic),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border(left: BorderSide(color: iconColor, width: 4)),
                        ),
                        code: const TextStyle(backgroundColor: Color(0xFFF1F3F5), color: Colors.redAccent, fontFamily: 'monospace'),
                      ),
                    ),
                    
                    // Safe Area Padding at the Bottom (Agar tidak terpotong)
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Widget untuk Badge/Pill yang Estetik
  Widget _buildPill(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textCol,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}