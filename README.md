# ZONARIDER — Flutter (versi penyempurnaan)

Versi ini mempertahankan identitas Dark Premium Graphite & Orange, dengan seluruh antarmuka berbahasa Indonesia.

## Yang diperbaiki
- Semua judul, tombol, petunjuk, dan navigasi diterjemahkan ke Bahasa Indonesia.
- Navigasi bawah: Beranda, Jelajahi, Bandingkan, Favorit.
- Kartu katalog diberi tombol simpan favorit langsung.
- Ilustrasi kartu dirapikan agar label merek tidak bertumpuk dengan ikon.
- Pencarian, filter merek, filter kategori, dan atur ulang filter.
- Detail motor dengan daftar spesifikasi yang tidak mengarang data kosong.
- Perbandingan motor mencakup kategori, tahun, kapasitas, tipe mesin, transmisi, tenaga, torsi, berat, dan harga.
- Halaman favorit memiliki petunjuk dan tombol kembali ke katalog saat masih kosong.
- Hasil API ditampilkan terpisah agar hasil untuk varian berbeda tidak otomatis dianggap cocok.
- Favorit dan cache hasil API tetap menggunakan SQLite.

## Menjalankan di VS Code
1. Cadangkan project lama.
2. Ekstrak ZIP ini.
3. Salin folder `lib`, `assets`, dan `pubspec.yaml` ke project Flutter lama (timpa file yang sama), atau buka folder hasil ekstrak sebagai project.
4. Jalankan:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Mengaktifkan API
Project menggunakan API Ninjas Motorcycles. Buat API key pada akun API Ninjas, lalu jalankan:
```bash
flutter run --dart-define=API_NINJAS_KEY=KUNCI_API_ANDA
```
Jangan mengunggah API key ke GitHub publik. Untuk aplikasi produksi, simpan kunci pada backend/proxy.

Jika API key belum dipasang, fitur katalog lokal dan favorit SQLite tetap dapat digunakan.

## Android
Lihat `PENGATURAN_ANDROID.txt` untuk label aplikasi dan izin internet.

## Catatan akurasi
Katalog berisi 24 model awal yang telah dipilih untuk pasar Indonesia. Data tahun, kapasitas, tenaga, torsi, harga, bobot, dan tinggi jok pada berkas JSON yang belum terverifikasi tetap `null`. Aplikasi menampilkan "Belum tersedia" alih-alih mengarang spesifikasi. Hasil API juga perlu dicocokkan dengan tahun dan varian Indonesia.
Foto produk resmi belum disertakan; area gambar memakai ilustrasi kategori agar tidak memakai foto yang salah atau tidak berizin.


## Foto motor lokal

Foto yang diberikan pengguna disimpan di `assets/motorcycles/` dan dipetakan melalui properti `imageAsset` pada `assets/data/motorcycles.json`. Foto tersedia untuk seluruh 24 model: 6 Honda, 6 Yamaha, 6 Suzuki, dan 6 Kawasaki. Setiap file gambar dipetakan berdasarkan model motor yang dituju; periksa kembali tahun/varian foto jika katalog diperbarui.

Jika mengganti foto, pertahankan nama file sesuai ID motor (contoh `honda_04.jpg`) atau ubah nilai `imageAsset` pada JSON.


## Pembaruan aset foto
- Suzuki: Burgman Street 125EX, GSX-R150, V-Strom 250 SX.
- Kawasaki: W175, KLX150, KLX230, Ninja 250, Ninja ZX-25R, Versys-X 250.
- Semua foto dipanggil melalui `Image.asset` menggunakan jalur pada `motorcycles.json`.
