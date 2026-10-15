import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../navigator.dart';
import '../checkout/Checkout.Data.dart';
import '../order_track/OrderTrack.Data.dart';
import 'Payment.Data.dart';

class PaymentCtrl {
  const PaymentCtrl();

  void selectProof() {
    paymentProofSelected.state = true;
  }

  Future<void> copyText(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin.'),
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void submit(BuildContext context) {
    if (!paymentProofSelected.state) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Pilih bukti transfer terlebih dahulu.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    paymentForm.submit(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      orderTrackCode.state = paymentOrderCode;
      orderTrackWhatsapp.state = checkoutWhatsapp.state;
      orderTrackExpectedWhatsapp.state = checkoutWhatsapp.state.replaceAll(
        RegExp(r'\D'),
        '',
      );
      orderTrackCompleted.state = false;
      orderTrackHasMatch.state = true;
      orderTrackHasSearched.state = true;
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Bukti bayar berhasil dikirim. Pesananmu sedang kami cek.'),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      nav.to('/order-track');
    });
  }
}
