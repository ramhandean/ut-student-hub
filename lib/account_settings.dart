import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});
  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final _nameController = TextEditingController();
  final _prodiController = TextEditingController();
  bool _isSaving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _nameController.text = user?.userMetadata?['full_name'] ?? "";
    _prodiController.text = user?.userMetadata?['prodi'] ?? "";
    _avatarUrl = user?.userMetadata?['avatar_url'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;

    setState(() => _isSaving = true);
    try {
      final file = File(image.path);
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fileName = 'avatars/$userId-${DateTime.now().millisecondsSinceEpoch}.png';

      await Supabase.instance.client.storage.from('avatars').upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'avatar_url': url}));
      setState(() => _avatarUrl = url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload gagal: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateInfo() async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
        'full_name': _nameController.text.trim(),
        'prodi': _prodiController.text.trim(),
      }));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil diperbarui!")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.fullscreen_rounded, color: Colors.blue),
            title: const Text("Lihat Foto Profil"),
            onTap: () {
              Navigator.pop(context);
              if (_avatarUrl != null) {
                _viewFullImage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Belum ada foto profil")),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: Colors.orange),
            title: const Text("Unggah Foto Baru"),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _viewFullImage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
              child: ImageFiltered(
                imageFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // 2. KONTEN FOTO
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'profile_pic',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        _avatarUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Padding(
                            padding: EdgeInsets.all(50),
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Tombol Close yang lebih cakep
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil", style: TextStyle(fontSize: 14)), actions: [
        IconButton(icon: const Icon(Icons.check, color: Colors.blueAccent), onPressed: _updateInfo)
      ]),
      body: ListView(padding: const EdgeInsets.all(25), children: [
        Center(
          child: GestureDetector(
            onTap: _showPickerOptions,
            child: Stack(children: [
              CircleAvatar(radius: 50, backgroundColor: Colors.orange, backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null, child: _avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null),
              if (_isSaving) const Positioned.fill(child: CircularProgressIndicator(color: Colors.white)),
              Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
            ]),
          ),
        ),
        const SizedBox(height: 30),
        _buildField(_nameController, "Nama Lengkap", Icons.badge),
        const SizedBox(height: 15),
        _buildField(_prodiController, "Program Studi", Icons.school),
      ]),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))));
  }
}