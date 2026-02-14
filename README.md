# <img src="assets/images/logo.png" width="200" alt="ut-student-hub logo">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)

**ut-student-hub** adalah aplikasi pendamping mahasiswa Universitas Terbuka yang dirancang untuk memusatkan segala kebutuhan akademik dalam satu tempat. Mulai dari manajemen catatan kuliah hingga akses cepat ke berbagai portal akademik UT.

## 🚀 Fitur Utama

- **Centralized Knowledge Base:** Sistem pencatatan materi kuliah berbasis Markdown dengan *Infinite Scroll pagination*.
- **Integrated Academic Portals:** Akses cepat ke MyUT, E-Learning (Tuton), SIA, dan Perpustakaan Digital melalui *In-App WebView*.
- **Profile Management:** Pengaturan profil dinamis terintegrasi dengan Supabase Auth & Storage.
- **Responsive Dark Mode:** Antarmuka modern yang nyaman untuk belajar.

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Backend:** Supabase (Database, Auth, Storage)
- **Key Libraries:** `supabase_flutter`, `flutter_dotenv`, `infinite_scroll_pagination`, `flutter_inappwebview`.

## 📦 Instalasi & Setup

1. **Clone repository:**
   ```bash
   git clone [https://github.com/ramhandean/ut-student-hub.git](https://github.com/ramhandean/ut-student-hub.git)
2. **Install dependencies:**
   ```bash
   flutter pub get
3. **Konfigurasi Environment:**
   Buat file `.env` di root project dan masukkan kredensial Supabase Anda:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
4. **Konfigurasi Database:**
   Gunakan file `ut_notes_backup.sql` di SQL Editor Supabase untuk menduplikasi struktur tabel dan kebijakan keamanan (RLS).
5. **Jalankan aplikasi:**
   ```bash
   flutter run
---

**Status Project:** *Archived* | Dibuat oleh [Dean Ramhan](https://www.google.com/search?q=https://engineroom.my.id)
