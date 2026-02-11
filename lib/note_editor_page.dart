import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteEditorPage extends StatefulWidget {
  final Map<String, dynamic>? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> with SingleTickerProviderStateMixin {
  late TextEditingController _titleC;
  late TextEditingController _contentC;
  late TabController _tabController;
  String _selectedCategory = 'Umum';
  bool _isSaving = false;

  final List<String> _categories = ['Umum', 'Tugas', 'Materi', 'Koding', 'Penting'];

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.note?['title'] ?? "");
    _contentC = TextEditingController(text: widget.note?['content'] ?? "");
    _selectedCategory = widget.note?['category'] ?? 'Umum';
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _saveNote() async {
    if (_titleC.text.isEmpty) return;
    setState(() => _isSaving = true);

    final data = {
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'title': _titleC.text,
      'content': _contentC.text,
      'category': _selectedCategory,
    };

    try {
      if (widget.note == null) {
        await Supabase.instance.client.from('ut_notes').insert(data);
      } else {
        await Supabase.instance.client.from('ut_notes').update(data).eq('id', widget.note!['id']);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: "Edit"),
            Tab(text: "Preview"),
          ],
        ),
        actions: [
          _isSaving
              ? const Center(child: Padding(padding: EdgeInsets.all(15), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : IconButton(icon: const Icon(Icons.done_all_rounded, color: Colors.blueAccent), onPressed: _saveNote),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // HALAMAN EDIT (WRITE MODE)
          _buildEditMode(isDark),

          // HALAMAN PREVIEW (READ MODE)
          _buildPreviewMode(isDark),
        ],
      ),
    );
  }

  Widget _buildEditMode(bool isDark) {
    return Column(
      children: [
        _buildCategoryBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _titleC,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: "Judul Materi", border: InputBorder.none),
              ),
              const Divider(),
              TextField(
                controller: _contentC,
                maxLines: null,
                style: GoogleFonts.firaCode(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Gunakan tombol di bawah untuk format...",
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        _buildMarkdownToolbar(),
      ],
    );
  }

  Widget _buildPreviewMode(bool isDark) {
    return Markdown(
      data: "# ${_titleC.text}\n---\n${_contentC.text}",
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        code: TextStyle(backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        codeblockDecoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: _categories.map((c) => Padding(
          padding: const EdgeInsets.only(right: 5),
          child: ChoiceChip(
            label: Text(c, style: const TextStyle(fontSize: 11)),
            selected: _selectedCategory == c,
            onSelected: (_) => setState(() => _selectedCategory = c),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMarkdownToolbar() {
    return Container(
      color: Colors.blueAccent.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolBtn(Icons.title, "# "),
          _toolBtn(Icons.format_bold, "**teks**"),
          _toolBtn(Icons.check_box_outlined, "- [ ] "),
          _toolBtn(Icons.code_rounded, "```\n\n```"),
          _toolBtn(Icons.format_list_bulleted, "* ")
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String syntax) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () {
        final text = _contentC.text;
        final selection = _contentC.selection;
        final newText = text.replaceRange(selection.start, selection.end, syntax);
        setState(() => _contentC.text = newText);
      },
    );
  }
}