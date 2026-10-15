import 'package:states_rebuilder/states_rebuilder.dart';

import '../checkout/Checkout.Data.dart';

final paymentProofSelected = RM.inject<bool>(
  () => false,
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

const paymentOrderCode = 'SEERA-261013-001';
int get paymentTotal => checkoutTotal;
const paymentBankName = 'Bank BCA';
const paymentAccountNumber = '1234567890';
const paymentAccountHolder = 'Seera.co_';
const paymentProofFileName = 'bukti-transfer.jpg';
