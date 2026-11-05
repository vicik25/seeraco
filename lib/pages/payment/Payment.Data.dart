import 'package:cross_file/cross_file.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/cart_item.dart';
import '../checkout/Checkout.Data.dart';

final paymentProofSelected = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final paymentProofFile = RM.inject<XFile?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final storePaymentSettings = RM.inject<Map<String, dynamic>?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final storePaymentSettingsError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final paymentForm = RM.injectForm();
final paymentCountdown = RM.injectStream<Duration>(
  () => Stream<Duration>.periodic(
    const Duration(minutes: 1),
    (tick) => const Duration(hours: 24) - Duration(minutes: tick + 1),
  ).take(const Duration(hours: 24).inMinutes),
  initialState: const Duration(hours: 24),
);

final paymentOrderCode = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final paymentOrderItems = RM.inject<List<CartItem>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final paymentCustomerName = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final paymentCustomerWhatsapp = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final paymentCustomerAddress = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final paymentOrderSubtotal = RM.inject<int>(
  () => 0,
  autoDisposeWhenNotUsed: false,
);
final paymentOrderShipping = RM.inject<int>(
  () => checkoutShipping,
  autoDisposeWhenNotUsed: false,
);
int get paymentTotal => paymentOrderSubtotal.state + paymentOrderShipping.state;
const paymentBankName = String.fromEnvironment(
  'SEERA_BANK_NAME',
  defaultValue: 'Informasi rekening',
);
const paymentAccountNumber = String.fromEnvironment('SEERA_BANK_ACCOUNT');
const paymentAccountHolder = String.fromEnvironment(
  'SEERA_BANK_HOLDER',
  defaultValue: 'Seera.co_',
);

String get currentPaymentBankName {
  final configured = storePaymentSettings.state?['nama_bank']
      ?.toString()
      .trim();
  return configured == null || configured.isEmpty
      ? paymentBankName
      : configured;
}

String get currentPaymentAccountNumber {
  final configured = storePaymentSettings.state?['nomor_rekening']
      ?.toString()
      .trim();
  return configured ?? paymentAccountNumber;
}

String get currentPaymentQrisUrl =>
    storePaymentSettings.state?['qris_url']?.toString().trim() ?? '';
