import 'package:states_rebuilder/states_rebuilder.dart';

final adminOrderStatusFilter = RM.inject<String>(
  () => 'Semua',
  autoDisposeWhenNotUsed: false,
);
final adminOrders = RM.inject<List<Map<String, dynamic>>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final adminProducts = RM.inject<List<Map<String, dynamic>>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final isAdminProductsLoading = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final adminProductsError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final isAdminOrdersLoading = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final adminOrdersError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);

const adminOrderStatuses = [
  'Semua',
  'Menunggu Pembayaran',
  'Proses',
  'Dikirim',
  'Selesai',
  'Gagal',
];
