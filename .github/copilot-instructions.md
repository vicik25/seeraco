# Panduan UI Seera.co (Flutter)

## Batasan perubahan

Proyek ini sudah berjalan. Untuk tugas UI, hanya ubah:

- File `*.View.dart`.
- `lib/core/theme/seera_colors.dart` dengan menambahkan token baru saja; jangan
  mengubah atau menghapus nilai yang sudah ada.
- Widget bersama di `lib/core/widgets/`.
- File tema UI baru di `lib/core/theme/` hanya jika diminta secara eksplisit.

Jangan ubah controller, Data, model, service, repository, provider, routing,
API/Firebase, `app.dart`, atau `main.dart`. Pertahankan nama, tanda tangan,
callback, controller, key, validator, data, dan urutan alur yang sudah ada.
Jangan menambah package.

Jika kebutuhan visual memerlukan data, state, atau callback yang belum
disediakan View/Controller, jangan menambahkannya sendiri; tanyakan terlebih
dahulu.

Gunakan gambar produk dan QRIS dari data asli. Placeholder hanya untuk desain
statis. Gunakan ikon Material yang sudah tersedia.

## Gaya

| Elemen | Gaya |
|---|---|
| Warna utama | Raspberry/pink Seera dari `SeeraColors` |
| Latar | Pastel pink lembut |
| Teks | Judul tebal, isi mudah dibaca |
| Kartu | Putih, radius 24–30, bayangan pink lembut |
| Tombol dan chip | Pill/stadium, area sentuh minimal 44 px |
| Input | Sudut membulat dan fokus pink |
| Responsif | Nyaman di ponsel dan desktop |
| Interaksi | Hover dan transisi halus bila didukung |

Gunakan token yang sudah tersedia di `lib/core/theme/seera_colors.dart` dan
widget bersama yang sudah ada di `lib/core/widgets/`. Jangan menulis ulang
warna yang sudah memiliki token.

## Cara mengerjakan halaman

1. Periksa View, Controller, Data, model, dan widget terkait untuk memahami
   kontrak data. File non-UI hanya dibaca, jangan diedit.
2. Ikuti alur dan callback yang ada; ubah presentasi saja.
3. Jika tidak ada padanan data atau interaksi untuk elemen desain, jangan
   membuat logika baru.
4. Verifikasi perubahan dengan analyzer serta tes yang relevan dan periksa
   tampilan pada ukuran ponsel dan desktop.
5. Jangan membuat branch, commit, mengubah dependency, atau mengubah entrypoint
   aplikasi tanpa permintaan eksplisit.

## Catatan pola halaman

- **Katalog:** filter kategori sebagai chip pill; kartu produk memakai gambar
  asli, nama, harga, dan data yang tersedia.
- **Detail produk:** foto besar, informasi di samping pada desktop dan di bawah
  pada ponsel; pilihan varian/jumlah dan tombol tetap memakai callback lama.
- **Keranjang:** kartu item dan ringkasan total; pertahankan fungsi kuantitas,
  hapus item, dan checkout yang sudah ada.
- **Checkout:** pertahankan controller, validasi, serta submit. Tampilkan
  ringkasan di samping pada desktop atau di bawah pada ponsel.
- **Pembayaran:** pertahankan alur pembayaran dan hanya tampilkan data yang
  disediakan Controller.
- **Halaman lain:** gunakan komponen dan token bersama secara konsisten tanpa
  mengubah perilaku bisnis.
