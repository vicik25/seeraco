import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_supabase.dart';
import '../../data/admin_session.dart';
import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/product.dart';
import '../../domains/_models/product_review.dart';
import '../catalog/Catalog.Data.dart';
import '../home/Home.Ctrl.dart';
import '../payment/Payment.Data.dart';
import 'Admin.Ctrl.dart';
import 'Admin.Data.dart';
import 'Admin.Metrics.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  var _selectedSection = 0;
  var _hasLoadedAdminData = false;
  var _isRefreshingAdminData = false;
  Timer? _adminRefreshTimer;

  void _loadAdminData() {
    if (_hasLoadedAdminData) return;
    _hasLoadedAdminData = true;
    AdminCtrl().refreshProducts();
    AdminCtrl().refreshOrders();
    loadStoreData(refresh: true);
    _adminRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshAdminData()),
    );
  }

  Future<void> _refreshAdminData() async {
    if (_isRefreshingAdminData || loggedInAdmin.state == null) return;
    _isRefreshingAdminData = true;
    try {
      await Future.wait([
        AdminCtrl().refreshProducts(),
        AdminCtrl().refreshOrders(),
      ]);
    } finally {
      _isRefreshingAdminData = false;
    }
  }

  void _signOut() {
    _adminRefreshTimer?.cancel();
    _adminRefreshTimer = null;
    loggedInAdmin.state = null;
    _hasLoadedAdminData = false;
    _selectedSection = 0;
    adminProducts.state = const [];
    adminOrders.state = const [];
    adminProductsError.state = null;
    adminOrdersError.state = null;
  }

  Widget _buildSection() {
    switch (_selectedSection) {
      case 1:
        return const _ProductManagement();
      case 2:
        return const _OrderManagement();
      case 3:
        return const _ReviewManagement();
      case 4:
        return const _StoreSettings();
      default:
        return const _DashboardSummary();
    }
  }

  @override
  void dispose() {
    _adminRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnReactive(() {
    final signedIn = loggedInAdmin.state != null;
    if (signedIn && !_hasLoadedAdminData) _loadAdminData();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', height: 34),
            const SizedBox(width: 12),
            const Text(
              'Panel Admin',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          if (signedIn)
            IconButton(
              tooltip: 'Keluar dari akun admin',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: signedIn ? _buildSection() : const _AdminSignIn(),
      bottomNavigationBar: signedIn
          ? NavigationBar(
              selectedIndex: _selectedSection,
              onDestinationSelected: (index) {
                setState(() => _selectedSection = index);
                if (index == 0) unawaited(_refreshAdminData());
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
            )
          : null,
    );
  });
}

class _AdminSignIn extends StatefulWidget {
  const _AdminSignIn();

  @override
  State<_AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<_AdminSignIn> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Masukkan username dan kata sandi admin.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final user = await SeeraSupabase.client
          .from('Users')
          .select()
          .eq('username', _username.text.trim())
          .eq('password', _password.text)
          .maybeSingle();
      if (user == null) {
        if (mounted) {
          setState(() => _error = 'Username atau kata sandi salah.');
        }
        return;
      }
      final admin = Map<String, dynamic>.from(user)..remove('password');
      loggedInAdmin.state = admin;
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                color: SeeraColors.pinkDeep,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Masuk ke Panel Admin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const ValueKey('admin-username'),
                controller: _username,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('admin-password'),
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _signIn(),
                decoration: const InputDecoration(
                  labelText: 'Kata sandi',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _isSubmitting ? null : _signIn,
                child: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Masuk'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masuk menggunakan akun admin pada tabel Users.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProductManagement extends StatelessWidget {
  const _ProductManagement();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      if (isAdminProductsLoading.state) {
        return const Center(child: CircularProgressIndicator());
      }
      if (adminProductsError.state != null) {
        return _AdminError(
          message: adminProductsError.state!,
          onRetry: AdminCtrl().refreshProducts,
        );
      }
      final products = adminProducts.state
          .map(Product.fromJson)
          .toList(growable: false);
      return RefreshIndicator(
        onRefresh: AdminCtrl().refreshProducts,
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
                  onPressed: () => _showProductEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
                IconButton(
                  tooltip: 'Muat ulang produk',
                  onPressed: AdminCtrl().refreshProducts,
                  icon: const Icon(Icons.refresh),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.category} · ${_currency(product.price)} · HPP ${_currency(product.costPrice)}',
                        ),
                        Text('Stok: ${_stockText(product.stock)}'),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Edit ${product.name}',
                          onPressed: () =>
                              _showProductEditor(context, product: product),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Hapus ${product.name}',
                          onPressed: () => _confirmDelete(context, product),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: SeeraColors.pinkDeep,
                          ),
                        ),
                      ],
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
    final id = TextEditingController(text: product?.id ?? '');
    final name = TextEditingController(text: product?.name ?? '');
    final category = TextEditingController(text: product?.category ?? '');
    final description = TextEditingController(text: product?.description ?? '');
    final price = TextEditingController(text: product?.price.toString() ?? '');
    final hpp = TextEditingController(
      text: product?.costPrice.toString() ?? '',
    );
    final stock = TextEditingController(text: product?.stock?.toString() ?? '');
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
                  if (product == null)
                    _AdminField(controller: id, label: 'Kode produk'),
                  _AdminField(controller: name, label: 'Nama produk'),
                  _AdminField(controller: category, label: 'Kategori'),
                  _AdminField(
                    controller: description,
                    label: 'Deskripsi',
                    maxLines: 3,
                  ),
                  _AdminField(controller: price, label: 'Harga', numeric: true),
                  _AdminField(controller: hpp, label: 'HPP', numeric: true),
                  _AdminField(
                    controller: stock,
                    label: 'Jumlah stok (unit)',
                    numeric: true,
                  ),
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
                          id: product?.id ?? id.text,
                          name: name.text,
                          category: category.text,
                          description: description.text,
                          price: price.text,
                          costPrice: hpp.text,
                          stock: stock.text,
                          marker: marker.text,
                          image: image,
                        );
                        id.dispose();
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
    stock.dispose();
    marker.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('${product.name} akan dihapus dari katalog.'),
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
      await AdminCtrl().deleteProduct(product.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produk gagal dihapus: $error')));
      }
    }
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

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary();

  @override
  Widget build(BuildContext context) => OnReactive(() {
    final isLoading =
        isAdminProductsLoading.state || isAdminOrdersLoading.state;
    final error = [
      adminProductsError.state,
      adminOrdersError.state,
    ].whereType<String>().join('\n');
    final metrics = AdminDashboardMetrics.fromData(
      products: adminProducts.state,
      orders: adminOrders.state,
    );
    final products = adminProducts.state
        .map(Product.fromJson)
        .toList(growable: false);
    Future<void> refresh() async {
      await Future.wait([
        AdminCtrl().refreshProducts(),
        AdminCtrl().refreshOrders(),
      ]);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ringkasan toko',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang ringkasan',
                onPressed: refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AdminError(message: error, onRetry: refresh),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                key: const ValueKey('admin-metric-revenue'),
                label: 'Omzet',
                icon: Icons.payments_outlined,
                value: isLoading ? '—' : _currency(metrics.revenue),
                hint: isLoading ? 'Memuat data...' : 'Pesanan dibayar',
              ),
              _MetricCard(
                key: const ValueKey('admin-metric-profit'),
                label: 'Estimasi laba',
                icon: Icons.trending_up,
                value: isLoading ? '—' : _currency(metrics.estimatedProfit),
                hint: isLoading ? 'Memuat data...' : 'Dihitung dari HPP produk',
              ),
              _MetricCard(
                key: const ValueKey('admin-metric-new-orders'),
                label: 'Pesanan baru',
                icon: Icons.shopping_bag_outlined,
                value: isLoading ? '—' : '${metrics.newOrders}',
                hint: isLoading ? 'Memuat data...' : 'Menunggu pembayaran',
              ),
              _MetricCard(
                key: const ValueKey('admin-metric-low-stock'),
                label: 'Stok menipis',
                icon: Icons.inventory_outlined,
                value: isLoading ? '—' : '${metrics.lowStockProducts}',
                hint: isLoading
                    ? 'Memuat data...'
                    : 'Produk dengan stok ≤ ${AdminDashboardMetrics.lowStockThreshold}',
              ),
              _MetricCard(
                key: const ValueKey('admin-metric-total-stock'),
                label: 'Total stok',
                icon: Icons.inventory_2_outlined,
                value: isLoading ? '—' : '${metrics.totalStock}',
                hint: isLoading
                    ? 'Memuat data...'
                    : metrics.productsWithoutStock == 0
                    ? 'Unit dari seluruh produk'
                    : '${metrics.productsWithoutStock} produk belum diatur',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InventorySummary(products: products),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey('admin-order-details-button'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _OrderDetailsPage(),
                ),
              ),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Lihat detail pesanan pelanggan'),
            ),
          ),
          const SizedBox(height: 16),
          const _UnavailablePanel(
            title: 'Penjualan lain',
            details:
                'Catat penjualan Shopee, TikTok, atau Offline setelah endpoint pencatatannya tersedia.',
            missing: 'Belum ada endpoint simpan_penjualan_lain.',
          ),
        ],
      ),
    );
  });
}

class _OrderDetailsPage extends StatelessWidget {
  const _OrderDetailsPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail pesanan pelanggan')),
    body: OnReactive(() {
      if (isAdminOrdersLoading.state) {
        return const Center(child: CircularProgressIndicator());
      }
      if (adminOrdersError.state != null) {
        return _AdminError(
          message: adminOrdersError.state!,
          onRetry: AdminCtrl().refreshOrders,
        );
      }
      final products = {
        for (final product in adminProducts.state)
          product['kode_produk']?.toString(): product,
      };
      final orders = adminOrders.state;
      if (orders.isEmpty) {
        return const _EmptyAdminState(message: 'Belum ada pesanan pelanggan.');
      }
      return RefreshIndicator(
        onRefresh: AdminCtrl().refreshOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final orderId = order['id_transaksi'];
            final details = order['Detail_Penjualan'];
            final items = details is List
                ? details.whereType<Map>().toList(growable: false)
                : const <Map>[];
            final subtotal = items.fold<int>(
              0,
              (sum, item) =>
                  sum +
                  _readMoney(item['harga_saat_ini']) *
                      _readMoney(item['jumlah']),
            );
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan #$orderId',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${order['status'] ?? 'Status belum diisi'} · ${_orderDate(order['tanggal_transaksi'])}',
                      style: const TextStyle(color: SeeraColors.greyMauve),
                    ),
                    const Divider(height: 24),
                    _OrderInfoLine(
                      label: 'Nama penerima',
                      value: order['nama_customer']?.toString(),
                    ),
                    _OrderInfoLine(
                      label: 'WhatsApp',
                      value: order['whatsapp']?.toString(),
                    ),
                    _OrderInfoLine(
                      label: 'Email',
                      value: order['email']?.toString(),
                    ),
                    _OrderInfoLine(
                      label: 'Alamat pengiriman',
                      value: order['alamat']?.toString(),
                    ),
                    _OrderInfoLine(
                      label: 'Catatan dari pembeli',
                      value: order['catatan']?.toString(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Barang dipesan',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    if (items.isEmpty)
                      const Text('Detail barang tidak tersedia.')
                    else
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  products[item['kode_produk']
                                              ?.toString()]?['nama_produk']
                                          ?.toString() ??
                                      item['kode_produk']?.toString() ??
                                      'Produk',
                                ),
                              ),
                              Text(
                                '${_readMoney(item['jumlah'])} × ${_currency(_readMoney(item['harga_saat_ini']))}',
                              ),
                            ],
                          ),
                        ),
                    const Divider(height: 24),
                    _OrderInfoLine(
                      label: 'Subtotal barang',
                      value: _currency(subtotal),
                    ),
                    _OrderInfoLine(
                      label: 'Ongkos kirim',
                      value: _currency(_readMoney(order['ongkir'])),
                    ),
                    _OrderInfoLine(
                      label: 'Kode unik',
                      value: _currency(_readMoney(order['kode_unik'])),
                    ),
                    _OrderInfoLine(
                      label: 'Total pembayaran',
                      value: _currency(_readMoney(order['total_bayar'])),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }),
  );
}

class _OrderInfoLine extends StatelessWidget {
  const _OrderInfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: SeeraColors.greyMauve)),
        SelectableText(value?.trim().isNotEmpty == true ? value! : '—'),
      ],
    ),
  );
}

class _OrderManagement extends StatelessWidget {
  const _OrderManagement();

  @override
  Widget build(BuildContext context) => OnReactive(() {
    if (isAdminOrdersLoading.state) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adminOrdersError.state != null) {
      return _AdminError(
        message: adminOrdersError.state!,
        onRetry: AdminCtrl().refreshOrders,
      );
    }
    final selectedStatus = adminOrderStatusFilter.state;
    final orders =
        adminOrders.state
            .where(
              (order) =>
                  selectedStatus == 'Semua' ||
                  order['status']?.toString() == selectedStatus,
            )
            .toList()
          ..sort((a, b) {
            final aHasProof = (a['bukti_bayar']?.toString() ?? '').isNotEmpty;
            final bHasProof = (b['bukti_bayar']?.toString() ?? '').isNotEmpty;
            return (bHasProof ? 1 : 0).compareTo(aHasProof ? 1 : 0);
          });
    return RefreshIndicator(
      onRefresh: AdminCtrl().refreshOrders,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Manajemen pesanan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang pesanan',
                onPressed: AdminCtrl().refreshOrders,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final status in adminOrderStatuses)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selectedStatus == status,
                      onSelected: (_) => adminOrderStatusFilter.state = status,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const _EmptyAdminState(
              message: 'Belum ada pesanan untuk filter ini.',
            )
          else
            for (final order in orders)
              _AdminOrderCard(
                order: order,
                products: {
                  for (final product in adminProducts.state)
                    product['kode_produk']?.toString() ?? '': product,
                },
              ),
        ],
      ),
    );
  });
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order, required this.products});

  final Map<String, dynamic> order;
  final Map<String, Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    final orderId = order['id_transaksi'];
    final proofUrl = order['bukti_bayar']?.toString() ?? '';
    final whatsapp = SeeraSupabase.normalizeWhatsapp(
      order['whatsapp']?.toString() ?? '',
    );
    final currentStatus = order['status']?.toString() ?? 'Menunggu Pembayaran';
    final selectedStatus = adminOrderStatuses.contains(currentStatus)
        ? currentStatus
        : 'Menunggu Pembayaran';
    final details = order['Detail_Penjualan'];
    final itemSummary = details is List
        ? details
              .whereType<Map>()
              .map((item) {
                final productId = item['kode_produk']?.toString();
                final productName =
                    products[productId]?['nama_produk']?.toString() ??
                    productId ??
                    'Produk';
                return '$productName × ${item['jumlah'] ?? 0}';
              })
              .join(', ')
        : '';
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pesanan #$orderId',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Lihat detail pelanggan dan barang',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => _AdminOrderDetailDialog(
                      order: order,
                      products: products,
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                ),
                if (proofUrl.isNotEmpty)
                  const Chip(
                    avatar: Icon(Icons.verified_outlined, size: 18),
                    label: Text('Bukti sudah masuk'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            Text(order['nama_customer']?.toString() ?? 'Pelanggan'),
            if (itemSummary.isNotEmpty) Text(itemSummary),
            Text(
              '${_currency(_readMoney(order['total_bayar']))} · ${order['status'] ?? 'Status belum diisi'}',
              style: const TextStyle(color: SeeraColors.greyMauve),
            ),
            if (proofUrl.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => HomeCtrl().openExternal(context, proofUrl),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Lihat bukti bayar'),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status pesanan',
                      isDense: true,
                    ),
                    items: [
                      for (final status in adminOrderStatuses.skip(1))
                        DropdownMenuItem(value: status, child: Text(status)),
                    ],
                    onChanged: (status) async {
                      if (status == null || status == currentStatus) return;
                      try {
                        await AdminCtrl().updateOrderStatus(
                          orderId: orderId,
                          status: status,
                        );
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status gagal diperbarui: $error'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                if (whatsapp.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Hubungi pembeli via WhatsApp',
                    onPressed: () {
                      final code = Uri.encodeComponent(
                        'Halo ${order['nama_customer'] ?? ''}, kami menghubungi terkait pesanan #$orderId di Seera.co_.',
                      );
                      HomeCtrl().openExternal(
                        context,
                        'https://wa.me/$whatsapp?text=$code',
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    color: SeeraColors.pinkDeep,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderDetailDialog extends StatelessWidget {
  const _AdminOrderDetailDialog({required this.order, required this.products});

  final Map<String, dynamic> order;
  final Map<String, Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    final details = order['Detail_Penjualan'];
    final items = details is List
        ? details.whereType<Map>().toList(growable: false)
        : const <Map>[];
    final subtotal = items.fold<int>(
      0,
      (sum, item) =>
          sum + _readMoney(item['harga_saat_ini']) * _readMoney(item['jumlah']),
    );

    return AlertDialog(
      title: Text('Detail pesanan #${order['id_transaksi']}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _OrderInfoLine(
                label: 'Status',
                value: order['status']?.toString(),
              ),
              _OrderInfoLine(
                label: 'Tanggal pesanan',
                value: _orderDate(order['tanggal_transaksi']),
              ),
              _OrderInfoLine(
                label: 'Nama penerima',
                value: order['nama_customer']?.toString(),
              ),
              _OrderInfoLine(
                label: 'WhatsApp',
                value: order['whatsapp']?.toString(),
              ),
              _OrderInfoLine(label: 'Email', value: order['email']?.toString()),
              _OrderInfoLine(
                label: 'Alamat pengiriman',
                value: order['alamat']?.toString(),
              ),
              _OrderInfoLine(
                label: 'Catatan dari pembeli',
                value: order['catatan']?.toString(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Barang yang dipesan',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              if (items.isEmpty)
                const Text('Detail barang tidak tersedia.')
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            products[item['kode_produk']
                                        ?.toString()]?['nama_produk']
                                    ?.toString() ??
                                item['kode_produk']?.toString() ??
                                'Produk',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_readMoney(item['jumlah'])} × ${_currency(_readMoney(item['harga_saat_ini']))}',
                        ),
                      ],
                    ),
                  ),
              const Divider(height: 24),
              _OrderInfoLine(
                label: 'Subtotal barang',
                value: _currency(subtotal),
              ),
              _OrderInfoLine(
                label: 'Ongkos kirim',
                value: _currency(_readMoney(order['ongkir'])),
              ),
              _OrderInfoLine(
                label: 'Kode unik',
                value: _currency(_readMoney(order['kode_unik'])),
              ),
              _OrderInfoLine(
                label: 'Total pembayaran',
                value: _currency(_readMoney(order['total_bayar'])),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class _StoreSettings extends StatefulWidget {
  const _StoreSettings();

  @override
  State<_StoreSettings> createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<_StoreSettings> {
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  var _isLoading = true;
  var _isSaving = false;
  var _isUploadingQris = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _bankName.dispose();
    _accountNumber.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      await AdminCtrl().refreshStoreSettings();
      final settings = storePaymentSettings.state;
      if (settings != null) {
        _bankName.text = settings['nama_bank']?.toString() ?? '';
        _accountNumber.text = settings['nomor_rekening']?.toString() ?? '';
      }
    } catch (_) {
      // The shared error state is rendered below.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBankDetails() async {
    setState(() => _isSaving = true);
    try {
      await AdminCtrl().saveStoreBankDetails(
        bankName: _bankName.text,
        accountNumber: _accountNumber.text,
      );
      if (mounted) {
        _showSettingsMessage('Informasi rekening berhasil disimpan.');
      }
    } catch (error) {
      if (mounted) _showSettingsMessage('Gagal menyimpan rekening: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _replaceQris() async {
    setState(() => _isUploadingQris = true);
    try {
      final uploaded = await AdminCtrl().selectAndUploadStoreQris();
      if (mounted && uploaded) {
        _showSettingsMessage('Gambar QRIS berhasil diperbarui.');
      }
    } catch (error) {
      if (mounted) _showSettingsMessage('Gagal memperbarui QRIS: $error');
    } finally {
      if (mounted) setState(() => _isUploadingQris = false);
    }
  }

  void _showSettingsMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => OnReactive(() {
    final loadError = storePaymentSettingsError.state;
    final settings = storePaymentSettings.state;
    final qrisUrl = settings?['qris_url']?.toString().trim() ?? '';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Pengaturan toko',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(36),
              child: CircularProgressIndicator(),
            ),
          )
        else if (loadError != null)
          _AdminError(message: loadError, onRetry: _loadSettings)
        else
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
                    controller: _bankName,
                    decoration: const InputDecoration(
                      labelText: 'Nama bank',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _accountNumber,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nomor rekening',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveBankDetails,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'QRIS toko',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: qrisUrl.isEmpty
                        ? Image.asset(
                            'assets/images/qris.jpeg',
                            height: 220,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            qrisUrl,
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image_outlined,
                                  size: 64,
                                  color: SeeraColors.greyMauve,
                                ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isUploadingQris ? null : _replaceQris,
                    icon: _isUploadingQris
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: const Text('Ganti gambar QRIS'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  });
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok per produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (products.isEmpty)
            const Text(
              'Belum ada data produk.',
              style: TextStyle(color: SeeraColors.greyMauve),
            )
          else
            for (var index = 0; index < products.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(products[index].name),
                subtitle: Text(products[index].category),
                trailing: Text(
                  _stockText(products[index].stock),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.hint,
  });

  final String label;
  final IconData icon;
  final String value;
  final String hint;

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
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            Text(
              hint,
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

String _stockText(int? stock) => stock == null ? 'Belum diatur' : '$stock unit';

String _orderDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'Tanggal tidak tersedia';
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}

int _readMoney(dynamic value) {
  if (value is num) return value.round();
  final normalized = value?.toString().replaceAll(RegExp(r'[^0-9-]'), '') ?? '';
  return int.tryParse(normalized) ?? 0;
}
