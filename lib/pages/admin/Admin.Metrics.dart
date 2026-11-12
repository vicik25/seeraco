class AdminDashboardMetrics {
  const AdminDashboardMetrics({
    required this.revenue,
    required this.estimatedProfit,
    required this.totalOrders,
    required this.newOrders,
    required this.lowStockProducts,
    required this.totalStock,
    required this.productsWithoutStock,
  });

  static const lowStockThreshold = 5;
  static const _revenueStatuses = {'proses', 'dikirim', 'selesai'};

  final int revenue;
  final int estimatedProfit;
  final int totalOrders;
  final int newOrders;
  final int lowStockProducts;
  final int totalStock;
  final int productsWithoutStock;

  factory AdminDashboardMetrics.fromData({
    required List<Map<String, dynamic>> products,
    required List<Map<String, dynamic>> orders,
  }) {
    final productCosts = {
      for (final product in products)
        if (product['kode_produk'] != null)
          product['kode_produk'].toString(): _readInt(product['hpp_satuan']),
    };
    var revenue = 0;
    var estimatedProfit = 0;
    var newOrders = 0;

    for (final order in orders) {
      final status = order['status']?.toString().trim().toLowerCase();
      if (status == 'menunggu pembayaran') newOrders++;
      if (!_revenueStatuses.contains(status)) continue;

      final details = order['Detail_Penjualan'];
      if (details is! List) continue;

      for (final detail in details.whereType<Map>()) {
        final productId = detail['kode_produk']?.toString();
        final quantity = _readInt(detail['jumlah']);
        final unitPrice = _readInt(detail['harga_saat_ini']);
        if (productId == null || quantity <= 0 || unitPrice < 0) continue;

        revenue += unitPrice * quantity;
        estimatedProfit +=
            (unitPrice - (productCosts[productId] ?? 0)) * quantity;
      }
    }

    var lowStockProducts = 0;
    var totalStock = 0;
    var productsWithoutStock = 0;
    for (final product in products) {
      final stock = product['stok'] ?? product['stock'];
      if (stock == null) {
        productsWithoutStock++;
        continue;
      }
      final quantity = _readInt(stock);
      totalStock += quantity;
      if (quantity <= lowStockThreshold) lowStockProducts++;
    }

    return AdminDashboardMetrics(
      revenue: revenue,
      estimatedProfit: estimatedProfit,
      totalOrders: orders.length,
      newOrders: newOrders,
      lowStockProducts: lowStockProducts,
      totalStock: totalStock,
      productsWithoutStock: productsWithoutStock,
    );
  }
}

int _readInt(dynamic value) {
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
