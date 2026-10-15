import 'package:states_rebuilder/states_rebuilder.dart';

class AboutPolicySection {
  const AboutPolicySection({required this.title, required this.body});

  final String title;
  final String body;
}

const aboutStory =
    'Seera.co_ berawal dari kecintaan pada warna-warna ceria dan aksesori kecil '
    'yang bisa membuat hari terasa lebih istimewa. Setiap jam dan gelang beads '
    'dirangkai dengan teliti, satu per satu, agar kamu bisa membawa sedikit '
    'keceriaan ke mana pun melangkah.';

const aboutValues = [
  ('Dibuat dengan hati', 'Setiap detail dirangkai dengan teliti dan penuh perhatian.'),
  ('Warna untuk semua', 'Aksesori ceria yang mudah dipadukan dengan gayamu.'),
  ('Belanja lebih tenang', 'Informasi pesanan dan kebijakan disampaikan dengan jelas.'),
];

final aboutPolicySections = RM.inject<List<AboutPolicySection>>(
  () => const [
    AboutPolicySection(
      title: 'Data yang kami kumpulkan',
      body:
          'Saat memesan, kami menggunakan nama, nomor WhatsApp, email, dan alamat '
          'yang kamu berikan untuk memproses pesanan serta menghubungimu tentang '
          'status pengiriman. Kami tidak menampilkan nomor telepon, email, atau alamat '
          'di daftar pembeli.',
    ),
    AboutPolicySection(
      title: 'Penggunaan dan penyimpanan data',
      body:
          'Informasi hanya digunakan untuk layanan pesanan, pembayaran, pengiriman, '
          'dan bantuan pelanggan. Bukti pembayaran disimpan secara terbatas untuk '
          'keperluan verifikasi transaksi dan tidak ditampilkan kepada publik.',
    ),
    AboutPolicySection(
      title: 'Hak pembeli',
      body:
          'Kamu dapat menghubungi Seera untuk meminta bantuan terkait informasi '
          'pesananmu. Nama di daftar pembeli ditampilkan secara disamarkan dan '
          'hanya jika kamu menyetujui pilihan tersebut saat checkout.',
    ),
    AboutPolicySection(
      title: 'Batas waktu pembayaran',
      body:
          'Pembayaran harus dilakukan maksimal 24 jam setelah pesanan dibuat. '
          'Pesanan yang belum dibayar setelah batas waktu akan dibatalkan dan '
          'stok akan dilepas kembali.',
    ),
    AboutPolicySection(
      title: 'Produk pre-order',
      body:
          'Produk dibuat berdasarkan pesanan. Estimasi pengerjaan dan kedatangan '
          'adalah 3 sampai 5 hari setelah pembayaran terkonfirmasi. Kami akan '
          'memberi kabar jika ada perubahan jadwal.',
    ),
    AboutPolicySection(
      title: 'Pembatalan dan refund',
      body:
          'Jika pesanan tidak dapat dipenuhi atau pembayaran terverifikasi berlebih, '
          'hubungi Seera melalui kanal bantuan. Pengembalian dana diproses setelah '
          'detail transaksi dikonfirmasi bersama pembeli.',
    ),
  ],
  autoDisposeWhenNotUsed: false,
);

const aboutSocialChannels = [
  ('Instagram', '@seera.co_', 'Ikuti cerita dan inspirasi aksesori Seera.'),
  ('TikTok Shop', 'Seera.co_', 'Lihat video produk dan koleksi terbaru.'),
  ('Shopee', 'Seera.co_', 'Temukan toko resmi Seera di Shopee.'),
];

final aboutSocialActionForm = RM.injectForm();
final aboutBuyerNavigationForm = RM.injectForm();
