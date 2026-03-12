import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart'; 
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({super.key, this.log, this.index, required this.controller, required this.currentUser});

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isPublic = false;
  
  // Tambahkan variabel kategori
  String _selectedCategory = "Software"; 
  final List<String> _categories = ["Mechanical", "Electronic", "Software"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _isPublic = widget.log?.isPublic ?? false;
    _selectedCategory = widget.log?.category ?? "Software";
    _descController.addListener(() { if (mounted) setState(() {}); });
  }

  void _save() async {
    if (_titleController.text.isEmpty) return;
    try {
      if (widget.log == null) {
        await widget.controller.addLog(
          _titleController.text, _descController.text, 
          widget.currentUser['uid'], widget.currentUser['teamId'],
          _selectedCategory, // Kirim kategori
          isPublic: _isPublic,
        );
      } else {
        await widget.controller.updateLog(
          widget.log!, 
          _titleController.text, _descController.text, 
          _selectedCategory, // Update kategori
          isPublic: _isPublic,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Tambah Log" : "Edit Log"),
          bottom: const TabBar(tabs: [Tab(text: "Editor"), Tab(text: "Pratinjau")]),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul")),
                const SizedBox(height: 16),
                
                // --- DROPDOWN KATEGORI ---
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Kategori Bidang", border: OutlineInputBorder()),
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Publikasikan ke Tim"),
                  value: _isPublic,
                  onChanged: (val) => setState(() => _isPublic = val),
                ),
                const SizedBox(height: 16),
                TextField(controller: _descController, maxLines: 10, decoration: const InputDecoration(hintText: "Isi Markdown...", border: OutlineInputBorder())),
              ]),
            ),
            Markdown(data: _descController.text),
          ],
        ),
      ),
    );
  }
}