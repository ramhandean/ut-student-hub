import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'note_editor_page.dart';

class NotesDashboard extends StatefulWidget {
  const NotesDashboard({super.key});
  @override
  State<NotesDashboard> createState() => _NotesDashboardState();
}

class _NotesDashboardState extends State<NotesDashboard> {
  final _searchC = TextEditingController();
  String _query = "";
  String _selectedFilter = "Semua";
  final List<String> _filters = ["Semua", "Umum", "Tugas", "Materi", "Koding", "Penting"];

  late final _pagingController = PagingController<int, Map<String, dynamic>>(
    getNextPageKey: (state) => state.lastPageIsEmpty
        ? null
        : (state.keys?.last ?? 0) + (state.pages?.last.length ?? 0),
    fetchPage: (pageKey) => _fetchNotesFromSupabase(pageKey),
  );

  Future<List<Map<String, dynamic>>> _fetchNotesFromSupabase(int pageKey) async {
    final client = Supabase.instance.client;
    var query = client.from('ut_notes').select();

    if (_selectedFilter != "Semua") {
      query = query.eq('category', _selectedFilter);
    }
    if (_query.isNotEmpty) {
      query = query.ilike('title', '%$_query%');
    }

    final List<Map<String, dynamic>> data = await query
        .order('created_at', ascending: false)
        .range(pageKey, pageKey + 9);

    return data;
  }

  String _getCleanContent(String? raw) {
    if (raw == null || raw.isEmpty) return "";

    String content = raw;
    content = content.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), (match) => match.group(1) ?? '');
    content = content.replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]+\)'), '');
    content = content.replaceAll(RegExp(r'([#*`\-_~>])'), '');
    return content.split('\n').map((line) => line.trimLeft()).join('\n').trim();
  }

  void _updateFilter() {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEditorPage()),
        ).then((_) => _pagingController.refresh()),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchC,
              onSubmitted: (v) {
                setState(() => _query = v.trim());
                _updateFilter();
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: "Cari materi & enter...",
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: _selectedFilter == f,
                  onSelected: (val) {
                    setState(() => _selectedFilter = f);
                    _updateFilter();
                  },
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) => PagedGridView<int, Map<String, dynamic>>(
                state: state,
                fetchNextPage: fetchNextPage,
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
                  itemBuilder: (context, item, index) => _buildNoteCard(item, isDark),
                  firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                  noItemsFoundIndicatorBuilder: (_) => const Center(child: Text("Belum ada catatan")),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteEditorPage(note: note)),
        ).then((_) => _pagingController.refresh()),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note['category']?.toUpperCase() ?? 'UMUM',
                  style: const TextStyle(fontSize: 9, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                note['title'] ?? 'Tanpa Judul',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  _getCleanContent(note['content']),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  onPressed: () => _deleteNote(note['id']),
                  visualDensity: VisualDensity.compact,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNote(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Catatan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('ut_notes').delete().eq('id', id);
      _pagingController.refresh();
    }
  }
}