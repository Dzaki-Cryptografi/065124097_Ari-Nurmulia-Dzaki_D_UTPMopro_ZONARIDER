
# ZONARIDER

ZONARIDER adalah aplikasi katalog motor berbasis Flutter yang dibuat untuk tugas UTP Mobile Programming. Aplikasi ini membantu pengguna melihat informasi motor dari beberapa merek yang ada di Indonesia.

## Fitur

- Melihat katalog motor Honda, Yamaha, Suzuki, dan Kawasaki.
- Mencari motor berdasarkan nama.
- Memfilter motor berdasarkan merek dan kategori.
- Melihat detail dan spesifikasi motor.
- Membandingkan dua motor.
- Menyimpan motor ke daftar favorit.
- Mengambil data tambahan melalui API Ninjas.

## Teknologi

- Flutter dan Dart
- SQLite untuk menyimpan favorit dan cache data API
- JSON untuk data katalog lokal
- API Ninjas untuk data motor tambahan

## Menjalankan aplikasi

Pastikan Flutter sudah terpasang. Buka folder proyek di VS Code, lalu jalankan perintah berikut di terminal:

```bash
flutter pub get
flutter run
```

## Penggunaan API

Aplikasi menggunakan API Ninjas untuk mengambil data tambahan. Untuk mengaktifkannya, gunakan API key milik sendiri:

```bash
flutter run --dart-define=API_NINJAS_KEY=KUNCI_API_ANDA
```

Jangan masukkan API key asli ke repository publik. Tanpa API key, fitur katalog lokal dan favorit tetap dapat digunakan.

## Catatan

Sebagian spesifikasi motor mungkin belum tersedia atau perlu diverifikasi sesuai tahun dan variannya. Jika data belum ada, aplikasi akan menampilkan keterangan bahwa data belum tersedia.

Foto motor disimpan di folder `assets/motorcycles/` dan dipetakan melalui file `assets/data/motorcycles.json`.
