import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_manager.dart';
import 'auth_page.dart';
import 'main_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://motkgjoujuncqvljqjdc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vdGtnam91anVuY3F2bGpxamRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2OTgyNzksImV4cCI6MjA4NjI3NDI3OX0.HpzQnrTqvFOI4KERZgBOM8VhCU7I_3JI--OIgxYjnX8',
  );
  runApp(const UTSuperApp());
}

class UTSuperApp extends StatefulWidget {
  const UTSuperApp({super.key});
  @override
  State<UTSuperApp> createState() => _UTSuperAppState();
}

class _UTSuperAppState extends State<UTSuperApp> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
    themeManager.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeManager.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF003366),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A84FF),
        scaffoldBackgroundColor: const Color(0xFF000000),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme.apply(bodyColor: Colors.white)),
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? const AuthPage()
          : const MainContainer(),
    );
  }
}