# Aturan Pembuatan Halaman / Fitur Baru (Flutter)

Setiap kali diminta membuat fitur atau halaman baru, WAJIB mengikuti struktur folder dan konvensi berikut:

1. **Struktur Domains (`lib/domains/`)**:
   - Model disimpan di: `lib/domains/_models/[nama_entity].dart`
   - Buat folder khusus fitur di: `lib/domains/[nama_entity]/`
     - State/Provider (`states_rebuilder`): `[nama_entity].prov.dart`
     - Service/API Request (Fungsi HTTP & logika API disatukan di sini): `[nama_entity].serv.dart`

2. **Struktur Pages (`lib/pages/[nama_entity]/`)**:
   - Sub-folder halaman fleksibel/opsional sesuai kebutuhan fitur project.
   - Setiap folder halaman WAJIB memisahkan file menjadi 3 komponen utama:
     - `[NamaPage].Ctrl.dart` (Controller / Logic)
     - `[NamaPage].Data.dart` (Data / Local State pendukung)
     - `[NamaPage].View.dart` (Tampilan / UI Widget)

3. **Routing & Navigation**:
   - Gunakan `navigation_builder` untuk berpindah halaman (`nav.to('/...')`).
   - Daftarkan route baru di file `lib/navigator.dart`.
