import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_supabase.dart';
import '../../domains/_models/cart_item.dart';
import '../../navigator.dart';
import '../cart/Cart.Data.dart';
import '../checkout/Checkout.Data.dart';
import '../order_track/OrderTrack.Data.dart';
import '../review/Review.Data.dart';
import 'Payment.Data.dart';

class PaymentCtrl {
  const PaymentCtrl();

  Future<void> selectProof(BuildContext context) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!context.mounted) return;
      if (file == null) return;
      final extension = file.name.split('.').last.toLowerCase();
      if (!const {'jpg', 'jpeg', 'png'}.contains(extension)) {
        _showMessage(context, 'Pilih berkas JPG atau PNG.');
        return;
      }
      if (await file.length() > 5 * 1024 * 1024) {
        if (!context.mounted) return;
        _showMessage(context, 'Ukuran foto maksimal 5 MB.');
        return;
      }
      if (!context.mounted) return;
      paymentProofFile.state = file;
      paymentProofSelected.state = true;
    } on PlatformException catch (error) {
      _showMessage(
        context,
        'Foto tidak dapat dipilih: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> copyText(BuildContext context, String text, String label) async {
    if (text.trim().isEmpty) {
      _showMessage(context, '$label belum tersedia.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    _showMessage(context, '$label berhasil disalin.');
  }

  void submit(BuildContext context) {
    final proof = paymentProofFile.state;
    if (proof == null) {
      _showMessage(context, 'Pilih bukti transfer terlebih dahulu.');
      return;
    }

    paymentForm.submit(() async {
      try {
        await SeeraSupabase.uploadPaymentProof(
          orderId:
              int.tryParse(paymentOrderCode.state) ?? paymentOrderCode.state,
          file: proof,
        );
        reviewProducts.state = cartItems.state
            .map((item) => item.product.name)
            .toList(growable: false);
        reviewRatings.state = List<int>.filled(reviewProducts.state.length, 0);
        reviewText.state = '';
        orderTrackItems.state = List<CartItem>.unmodifiable(cartItems.state);
        orderTrackTotal.state = checkoutTotal;
        orderTrackCode.state = paymentOrderCode.state;
        orderTrackCustomerName.state = checkoutName.state.trim();
        savedOrderCode.state = paymentOrderCode.state;
        orderTrackWhatsapp.state = checkoutWhatsapp.state;
        savedOrderWhatsapp.state = checkoutWhatsapp.state;
        orderTrackAddress.state = checkoutAddress.state;
        orderTrackStatus.state = 'Proses';
        orderTrackExpectedWhatsapp.state = checkoutWhatsapp.state.replaceAll(
          RegExp(r'\D'),
          '',
        );
        orderTrackCompleted.state =
            orderTrackStatus.state.toLowerCase() == 'selesai';
        orderTrackHasMatch.state = true;
        orderTrackHasSearched.state = true;
        if (!context.mounted) return;
        _showMessage(context, 'Bukti bayar diterima. Status pesanan: Proses.');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        nav.to('/order-track');
      } catch (error) {
        if (context.mounted) {
          _showMessage(context, 'Bukti bayar gagal dikirim: $error');
        }
      }
    });
  }

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.fixed),
    );
  }
}
