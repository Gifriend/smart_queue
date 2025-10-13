# SmartQueue - Aplikasi Antrian Flutter

Aplikasi manajemen antrian sederhana yang dibangun menggunakan Flutter dan Firebase (Cloud Firestore) untuk sinkronisasi data secara *real-time* antar perangkat.

## ✨ Fitur Utama

-   **Ambil Nomor Antrian**: Pengguna dapat menambahkan diri ke dalam antrian dengan memasukkan nama dan memilih jenis layanan (Tarik Tunai, Setor Tunai, dll).
-   **Daftar Antrian Real-time**: Menampilkan daftar antrian saat ini yang terupdate secara otomatis di semua perangkat yang terhubung.
-   **Panggil Berikutnya**: Fitur untuk operator memanggil antrian terdepan. Antrian yang dipanggil akan otomatis terhapus dari daftar.
-   **Manajemen Antrian**: Opsi untuk menghapus satu item antrian secara spesifik atau membersihkan seluruh daftar antrian (dengan dialog konfirmasi).
-   **Ringkasan Status**: Menampilkan total antrian yang ada dan nomor antrian yang akan dipanggil selanjutnya.
-   **Persistensi Multi-Perangkat**: Menggunakan Cloud Firestore, data antrian tersimpan di cloud dan tersinkronisasi, memungkinkan adanya layar operator dan layar display publik yang berbeda.

## 🚀 Cara Menjalankan Aplikasi

1.  **Prasyarat**:
    * Pastikan Anda telah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
    * Buat sebuah proyek baru di [Firebase Console](https://console.firebase.google.com/).
    * Aktifkan **Cloud Firestore** pada proyek Firebase Anda.

2.  **Konfigurasi Firebase**:
    * Install Firebase CLI: `npm install -g firebase-tools`.
    * Login ke Firebase: `firebase login`.
    * Install FlutterFire CLI: `dart pub global activate flutterfire_cli`.
    * Konfigurasi proyek Anda dengan menjalankan perintah berikut di root folder proyek Flutter Anda:
        ```bash
        flutterfire configure
        ```
    * Ikuti petunjuk di layar untuk menghubungkan proyek Flutter dengan proyek Firebase Anda. Perintah ini akan otomatis membuat file `lib/firebase_options.dart`.

3.  **Install Dependensi**:
    * Jalankan perintah berikut di terminal:
        ```bash
        flutter pub get
        ```

4.  **Jalankan Aplikasi**:
    * Hubungkan perangkat atau jalankan emulator.
    * Jalankan perintah:
        ```bash
        flutter run
        ```
