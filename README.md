```markdown
# ut-student-hub 🎓
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)

**ut-student-hub** adalah aplikasi pendamping mahasiswa Universitas Terbuka yang dirancang untuk memusatkan segala kebutuhan akademik dalam satu tempat. Mulai dari manajemen catatan kuliah hingga akses cepat ke berbagai portal akademik UT.

## 🚀 Fitur Utama

- **Centralized Knowledge Base:** Sistem pencatatan materi kuliah berbasis Markdown. Menggunakan *Infinite Scroll pagination* (v5.1.1) untuk performa yang optimal dan efisien.
- **Integrated Academic Portals:** Akses cepat ke MyUT, E-Learning (Tuton), SIA, dan Perpustakaan Digital melalui In-App WebView terintegrasi.
- **Clean Note Preview:** Dashboard cerdas dengan fitur *markdown cleaner* yang menjaga struktur baris baru (line breaks) agar catatan tetap terstruktur di dashboard.
- **Profile Management:** Pengaturan profil dinamis yang terintegrasi dengan Supabase Auth dan Storage untuk sinkronisasi data mahasiswa secara real-time.
- **Responsive Dark Mode:** Antarmuka modern yang mendukung tema gelap untuk kenyamanan belajar di malam hari.

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Backend:** Supabase (Realtime Database, Authentication, Storage)
- **Pagination:** Infinite Scroll Pagination (^5.1.1)
- **UI & Tools:** Google Fonts, Flutter Markdown Plus, Flutter InAppWebView

## 📸 Screenshots

| Dashboard & Filters | Markdown Editor | Portal UT |
|---|---|---|
| ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard+UI) | ![Editor](https://via.placeholder.com/200x400?text=Editor+UI) | ![Portal](https://via.placeholder.com/200x400?text=Portal+UI) |

> **Note:** Upload screenshot asli dari HP kamu ke folder `assets/` dan ganti link di atas untuk tampilan yang lebih menarik.

## 📦 Instalasi

1. **Clone repository:**
   ```bash
   git clone [https://github.com/USERNAME_KAMU/ut-student-hub.git](https://github.com/USERNAME_KAMU/ut-student-hub.git)

```

2. **Install dependencies:**
```bash
flutter pub get

```


3. **Konfigurasi Supabase:**
Inisialisasi `Supabase.initialize` pada `main.dart` menggunakan URL dan Anon Key dari project Supabase kamu.
4. **Jalankan aplikasi:**
```bash
flutter run

```



---

Dibuat oleh [Dean Ramhan](https://www.google.com/search?q=https://engineroom.my.id) sebagai bagian dari pengembangan ekosistem aplikasi pendukung mahasiswa Sistem Informasi.

```