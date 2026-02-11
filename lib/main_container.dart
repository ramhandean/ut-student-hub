import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'account_settings.dart';
import 'theme_manager.dart';
import 'notes_dashboard.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentTitle = "Catatan Kuliah";
  String _currentUrl = "internal_dashboard";
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _isDesktop = true;
  bool _showToolbar = false;

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // Daftar URL Lengkap Universitas Terbuka
  final Map<String, List<Map<String, String>>> _utCategories = {
    "Personal Space": [
      {"name": "Catatan Kuliah", "url": "internal_dashboard", "icon": "edit_note_rounded"},
    ],
    "1. Akses Utama & Akun": [
      {"name": "MyUT (Portal Utama)", "url": "https://myut.ut.ac.id/", "icon": "dashboard_customize_rounded"},
      {"name": "Admisi SIA", "url": "https://admisi-sia.ut.ac.id/", "icon": "app_registration_rounded"},
      {"name": "Informasi Registrasi", "url": "https://registrasi.ut.ac.id/", "icon": "info_outline_rounded"},
    ],
    "2. Pembelajaran & Tugas": [
      {"name": "E-Learning (Tuton)", "url": "https://elearning.ut.ac.id/", "icon": "school_rounded"},
      {"name": "Tugas Mata Kuliah (TMK)", "url": "http://tmk.ut.ac.id/", "icon": "assignment_rounded"},
      {"name": "Silayar (OSMB/PKBJJ)", "url": "https://silayar.ut.ac.id/", "icon": "co_present_rounded"},
      {"name": "MOOCs UT", "url": "https://moocs.ut.ac.id/", "icon": "laptop_chromebook_rounded"},
    ],
    "3. Ujian & Kelulusan": [
      {"name": "Take Home Exam (THE)", "url": "https://the.ut.ac.id/", "icon": "description_rounded"},
      {"name": "Sistem Ujian Online (SUO)", "url": "http://suo.ut.ac.id/", "icon": "computer_rounded"},
      {"name": "Aksi UT (Yudisium)", "url": "https://aksi.ut.ac.id/", "icon": "workspace_premium_rounded"},
      {"name": "SILA (Tracer Alumni)", "url": "https://sila.ut.ac.id/", "icon": "people_alt_rounded"},
    ],
    "4. Perpustakaan & Bantuan": [
      {"name": "Perpustakaan Pusat", "url": "https://pustaka.ut.ac.id/", "icon": "local_library_rounded"},
      {"name": "Ruang Baca Virtual (RBV)", "url": "https://pustaka.ut.ac.id/lib/rbv/", "icon": "menu_book_rounded"},
      {"name": "Halo UT (Helpdesk)", "url": "https://hallo-ut.ut.ac.id/", "icon": "support_agent_rounded"},
      {"name": "KMS (Panduan/FAQ)", "url": "https://kms.ut.ac.id/", "icon": "help_center_rounded"},
    ],
  };

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "edit_note_rounded": return Icons.edit_note_rounded;
      case "dashboard_customize_rounded": return Icons.dashboard_customize_rounded;
      case "app_registration_rounded": return Icons.app_registration_rounded;
      case "school_rounded": return Icons.school_rounded;
      case "assignment_rounded": return Icons.assignment_rounded;
      case "co_present_rounded": return Icons.co_present_rounded;
      case "description_rounded": return Icons.description_rounded;
      case "computer_rounded": return Icons.computer_rounded;
      case "local_library_rounded": return Icons.local_library_rounded;
      case "menu_book_rounded": return Icons.menu_book_rounded;
      case "support_agent_rounded": return Icons.support_agent_rounded;
      case "help_center_rounded": return Icons.help_center_rounded;
      case "workspace_premium_rounded": return Icons.workspace_premium_rounded;
      case "people_alt_rounded": return Icons.people_alt_rounded;
      case "laptop_chromebook_rounded": return Icons.laptop_chromebook_rounded;
      default: return Icons.link_rounded;
    }
  }

  void _navigate(String name, String url) {
    setState(() { _currentTitle = name; _currentUrl = url; _progress = 0; _showToolbar = false; });
    _scaffoldKey.currentState?.closeDrawer();
    if (url != "internal_dashboard") {
      Future.delayed(const Duration(milliseconds: 300), () {
        _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_currentTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_currentUrl != "internal_dashboard")
            IconButton(
              icon: Icon(_showToolbar ? Icons.close_rounded : Icons.explore_rounded, color: Colors.blueAccent),
              onPressed: () => setState(() => _showToolbar = !_showToolbar),
            ),
          IconButton(
            icon: Icon(themeManager.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
            onPressed: () => themeManager.toggleTheme(),
          ),
        ],
      ),
      drawer: _buildDrawer(isDark),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_currentUrl == "internal_dashboard") const NotesDashboard()
            else Column(children: [
              if (_progress < 1.0)
                LinearProgressIndicator(value: _progress, color: Colors.blueAccent, minHeight: 2.5, backgroundColor: Colors.transparent),
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    userAgent: _isDesktop ? "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" : null,
                    preferredContentMode: _isDesktop ? UserPreferredContentMode.DESKTOP : UserPreferredContentMode.MOBILE,
                  ),
                  onWebViewCreated: (c) => _webViewController = c,
                  onProgressChanged: (c, p) => setState(() => _progress = p / 100),
                ),
              ),
            ]),
            if (_currentUrl != "internal_dashboard")
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCirc,
                bottom: _showToolbar ? 30.0 : -100.0,
                child: _buildBrowserTools(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(children: [
        _buildHeader(isDark),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _utCategories.entries.map((cat) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
                  child: Text(cat.key.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent.withOpacity(0.7), letterSpacing: 1.1)),
                ),
                ...cat.value.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: _currentTitle == item['name'] ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(_getIcon(item['icon']!), size: 18, color: _currentTitle == item['name'] ? Colors.blueAccent : Colors.grey),
                    title: Text(item['name']!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
                    onTap: () => _navigate(item['name']!, item['url']!),
                  ),
                )).toList(),
              ],
            )).toList(),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.manage_accounts_rounded, color: Colors.blueAccent),
          title: const Text("Pengaturan Akun", style: TextStyle(fontSize: 13)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettings()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          onTap: () async => await Supabase.instance.client.auth.signOut(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildHeader(bool isDark) {
    final user = Supabase.instance.client.auth.currentUser;
    final String displayName = user?.userMetadata?['full_name'] ?? "Dean Ramhan";
    final String displayProdi = user?.userMetadata?['prodi'] ?? "Sistem Informasi";
    final String? avatarUrl = user?.userMetadata?['avatar_url'];

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), Colors.black]
              : [const Color(0xFF003366), const Color(0xFF004080)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isDark ? Colors.grey[800] : Colors.orangeAccent,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person_rounded, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))]
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayProdi,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserTools(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolBtn(Icons.arrow_back_ios_new_rounded, () => _webViewController?.goBack()),
          _toolBtn(Icons.arrow_forward_ios_rounded, () => _webViewController?.goForward()),
          _toolBtn(Icons.refresh_rounded, () => _webViewController?.reload()),
          Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 8)),
          _toolBtn(_isDesktop ? Icons.desktop_mac_rounded : Icons.smartphone_rounded, () {
            setState(() => _isDesktop = !_isDesktop);
            _webViewController?.reload();
          }, color: Colors.blueAccent),
          _toolBtn(Icons.home_filled, () => _navigate("Knowledge Base", "internal_dashboard"), color: Colors.orangeAccent),
          _toolBtn(Icons.expand_more_rounded, () => setState(() => _showToolbar = false), color: Colors.grey),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return IconButton(icon: Icon(icon, color: color, size: 18), onPressed: onTap);
  }
}