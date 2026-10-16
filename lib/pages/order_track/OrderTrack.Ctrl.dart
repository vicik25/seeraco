import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../navigator.dart';
import 'OrderTrack.Data.dart';

class OrderTrackCtrl {
  const OrderTrackCtrl();

  void updateCode(String value) => orderTrackCode.state = value;

  void updateWhatsapp(String value) => orderTrackWhatsapp.state = value;

  void submit(BuildContext context) {
    if (orderTrackCode.state.trim().isEmpty ||
        orderTrackWhatsapp.state.trim().isEmpty) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode pesanan dan nomor WhatsApp.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    orderTrackForm.submit(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      final normalizedWhatsapp = orderTrackWhatsapp.state.replaceAll(
        RegExp(r'\D'),
        '',
      );
      final normalizedCode = orderTrackCode.state.trim().toUpperCase();
      final isMatched =
          normalizedCode == savedOrderCode.state.toUpperCase() &&
          normalizedWhatsapp ==
              savedOrderWhatsapp.state.replaceAll(RegExp(r'\D'), '');
      orderTrackHasMatch.state = isMatched;
      orderTrackCompleted.state =
          isMatched && orderTrackStatus.state.toLowerCase() == 'selesai';
      orderTrackHasSearched.state = true;
    });
  }

  void openPayment() => nav.to('/payment');
}
