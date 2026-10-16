import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/product.dart';
import '../../domains/_models/product_review.dart';
import '../catalog/Catalog.Data.dart';
import '../payment/Payment.Data.dart';
import 'Admin.Ctrl.dart';
import 'Admin.Data.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  var _selectedSection = 0;

  @override
  void initState() {
    super.initState();
    loadStoreData();
  }

  Widget _buildSection() {
    switch (_selectedSection) {
      case 1:
        return const _ProductManagement();
      case 2:
        return const _OrderManagementUnavailable();
      case 3:
        return const _ReviewManagement();
      case 4:
        return const _SettingsUnavailable();
      default:
        return const _DashboardUnavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', height: 34),
            const SizedBox(width: 12),
            const Text(
              'Panel Admin',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: _buildSection(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedSection,
        onDestinationSelected: (index) {
          setState(() => _selectedSection = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_outlined),
            label: 'Ulasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class _ProductManagement extends StatelessWidget {
  const _ProductManagement();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      if (isCatalogLoading.state) {
        return const Center(child: CircularProgressIndicator());
      }
      if (catalogLoadError.state != null) {
        return _AdminError(
          message: catalogLoadError.state!,
          onRetry: AdminCtrl().refresh,
        );
      }
      final products = catalogProducts.state;
      return RefreshIndicator(
        onRefresh: AdminCtrl().refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Produk',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: AdminCtrl().refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat ulang'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const _EmptyAdminState(message: 'Belum ada produk dari server.')
            else
              for (final product in products)
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ProductArtwork(product: product),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.category} · ${_currency(product.price)} · HPP ${_currency(product.costPrice)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Edit ${product.name}',
                      onPressed: () =>
                          _showProductEditor(context, product: product),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
          ],
        ),
      );
    });
  }

  Future<void> _showProductEditor(
    BuildContext context, {
    Product? product,
  }) async {
    final name = TextEditingController(text: product?.name ?? '');
    final category = TextEditingController(text: product?.category ?? '');
    final description = TextEditingController(text: product?.description ?? '');
    final price = TextEditingController(text: product?.price.toString() ?? '');
    final hpp = TextEditingController(
      text: product?.costPrice.toString() ?? '',
    );
    final marker = TextEditingController(text: product?.marker ?? '');
    XFile? image;
    var saving = false;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Tambah produk' : 'Edit produk'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AdminField(controller: name, label: 'Nama produk'),
                  _AdminField(controller: category, label: 'Kategori'),
                  _AdminField(
                    controller: description,
                    label: 'Deskripsi',
                    maxLines: 3,
                  ),
                  _AdminField(controller: price, label: 'Harga', numeric: true),
                  _AdminField(controller: hpp, label: 'HPP', numeric: true),
                  _AdminField(controller: marker, label: 'Penanda'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) setState(() => image = picked);
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: Text(image?.name ?? 'Pilih gambar produk'),
                    ),
                  ),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await AdminCtrl().saveProduct(
                          id: product?.id ?? '',
                          name: name.text,
                          category: category.text,
                          description: description.text,
                          price: price.text,
                          costPrice: hpp.text,
                          marker: marker.text,
                          image: image,
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (exception) {
                        setState(() {
                          error = exception.toString();
                          saving = false;
                        });
                      }
                    },
              child: Text(saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    category.dispose();
    description.dispose();
    price.dispose();
    hpp.dispose();
    marker.dispose();
  }
}

class _ReviewManagement extends StatelessWidget {
  const _ReviewManagement();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      if (isReviewsLoading.state) {
        return const Center(child: CircularProgressIndicator());
      }
      if (reviewsLoadError.state != null) {
        return _AdminError(
          message: reviewsLoadError.state!,
          onRetry: AdminCtrl().refresh,
        );
      }
      final reviews = productReviews.state;
      return RefreshIndicator(
        onRefresh: AdminCtrl().refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Ulasan pelanggan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              const _EmptyAdminState(message: 'Belum ada ulasan dari server.')
            else
              for (final review in reviews) _ReviewAdminCard(review: review),
          ],
        ),
      );
    });
  }
}

class _ReviewAdminCard extends StatelessWidget {
  const _ReviewAdminCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: ListTile(
      title: Text(review.productName.isEmpty ? 'Produk' : review.productName),
      subtitle: Text(
        '${review.customerName} · ${review.rating}/5\n${review.comment}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: 'Hapus ulasan',
        icon: const Icon(Icons.delete_outline, color: SeeraColors.pinkDeep),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hapus ulasan?'),
              content: const Text('Ulasan ini akan dihapus dari toko.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
          if (confirmed != true || !context.mounted) return;
          try {
            await AdminCtrl().deleteReview(review);
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ulasan gagal dihapus: $error')),
              );
            }
          }
        },
      ),
    ),
  );
}

class _DashboardUnavailable extends StatelessWidget {
  const _DashboardUnavailable();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Ringkasan toko',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          _MetricCard(label: 'Omzet', icon: Icons.payments_outlined),
          _MetricCard(label: 'Laba', icon: Icons.trending_up),
          _MetricCard(label: 'Pesanan baru', icon: Icons.shopping_bag_outlined),
          _MetricCard(label: 'Stok menipis', icon: Icons.inventory_outlined),
        ],
      ),
      const SizedBox(height: 16),
      const _UnavailablePanel(
        title: 'Penjualan lain',
        details:
            'Catat penjualan Shopee, TikTok, atau Offline setelah endpoint pencatatannya tersedia.',
        missing: 'Belum ada endpoint simpan_penjualan_lain.',
      ),
    ],
  );
}

class _OrderManagementUnavailable extends StatelessWidget {
  const _OrderManagementUnavailable();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Manajemen pesanan',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      OnReactive(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final status in adminOrderStatuses)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: adminOrderStatusFilter.state == status,
                    onSelected: (_) => adminOrderStatusFilter.state = status,
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      const _UnavailablePanel(
        title: 'Daftar pesanan belum terhubung',
        details:
            'Urutan bukti masuk, perubahan status/refund, dan draf WhatsApp membutuhkan data pesanan dari server.',
        missing: 'API get_pesanan dan update_status_pesanan belum disertakan.',
      ),
    ],
  );
}

class _SettingsUnavailable extends StatelessWidget {
  const _SettingsUnavailable();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Pengaturan toko',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Rekening bank',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: paymentBankName,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Nama bank'),
              ),
              TextFormField(
                initialValue: paymentAccountNumber.isEmpty
                    ? 'Belum dikonfigurasi'
                    : paymentAccountNumber,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Nomor rekening'),
              ),
              const SizedBox(height: 18),
              const Text(
                'QRIS default',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Image.asset('assets/images/qris.jpeg', height: 180),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.upload_file),
                label: const Text('Ganti gambar QRIS'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tampilan ini hanya baca. Edit rekening dan QRIS belum dapat disimpan karena server belum menyediakan API pengaturan toko.',
                style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      const _UnavailablePanel(
        title: 'Sinkronisasi pengaturan',
        details:
            'Perubahan rekening dan QRIS perlu tersimpan di backend supaya tidak hanya berlaku pada satu perangkat.',
        missing:
            'API baca/simpan pengaturan toko dan unggah QRIS belum disertakan.',
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: SeeraColors.pinkDeep),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: SeeraColors.greyMauve)),
            const Text(
              '—',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Menunggu API',
              style: TextStyle(fontSize: 11, color: SeeraColors.greyMauve),
            ),
          ],
        ),
      ),
    ),
  );
}

class _UnavailablePanel extends StatelessWidget {
  const _UnavailablePanel({
    required this.title,
    required this.details,
    required this.missing,
  });

  final String title;
  final String details;
  final String missing;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Icon(Icons.info_outline, color: SeeraColors.pinkDeep),
          const SizedBox(height: 12),
          Text(details),
          const SizedBox(height: 12),
          Text(missing, style: const TextStyle(color: SeeraColors.greyMauve)),
        ],
      ),
    ),
  );
}

class _AdminError extends StatelessWidget {
  const _AdminError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Text(message, textAlign: TextAlign.center),
  );
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.label,
    this.numeric = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool numeric;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

String _currency(int value) =>
    'Rp${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
