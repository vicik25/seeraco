import 'package:flutter_test/flutter_test.dart';
import 'package:seeraco/pages/admin/Admin.Metrics.dart';

void main() {
  test('summarizes configured stock and counts low-stock products', () {
    final metrics = AdminDashboardMetrics.fromData(
      products: [
        {'kode_produk': 'watch', 'stok': 3},
        {'kode_produk': 'bracelet', 'stok': '14'},
        {'kode_produk': 'ring', 'stok': 5},
        {'kode_produk': 'necklace', 'stok': null},
      ],
      orders: const [],
    );

    expect(metrics.totalStock, 22);
    expect(metrics.productsWithoutStock, 1);
    expect(metrics.lowStockProducts, 2);
  });

  test('counts new orders regardless of status casing or whitespace', () {
    final metrics = AdminDashboardMetrics.fromData(
      products: const [],
      orders: [
        {'status': 'Menunggu Pembayaran'},
        {'status': ' menunggu pembayaran '},
        {'status': 'Proses'},
      ],
    );

    expect(metrics.totalOrders, 3);
    expect(metrics.newOrders, 2);
  });
}
