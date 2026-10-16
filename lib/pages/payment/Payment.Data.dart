import 'package:cross_file/cross_file.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../checkout/Checkout.Data.dart';

final paymentProofSelected = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final paymentProofFile = RM.inject<XFile?>(
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
int get paymentTotal => checkoutTotal;
const paymentBankName = String.fromEnvironment(
  'SEERA_BANK_NAME',
  defaultValue: 'Informasi rekening',
);
const paymentAccountNumber = String.fromEnvironment('SEERA_BANK_ACCOUNT');
const paymentAccountHolder = String.fromEnvironment(
  'SEERA_BANK_HOLDER',
  defaultValue: 'Seera.co_',
);
