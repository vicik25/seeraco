import 'package:states_rebuilder/states_rebuilder.dart';

final adminOrderStatusFilter = RM.inject<String>(
  () => 'Semua',
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
