import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_supabase.dart';
import '../../navigator.dart';
import '../cart/Cart.Data.dart';
import '../payment/Payment.Data.dart';
import 'Checkout.Data.dart';

class CheckoutCtrl {
  const CheckoutCtrl();

  void updateName(String value) {
    checkoutName.state = value;
    checkoutNameError.state = null;
  }

  void updateWhatsapp(String value) {
    checkoutWhatsapp.state = value;
    checkoutWhatsappError.state = null;
  }

  void updateEmail(String value) {
    checkoutEmail.state = value;
    checkoutEmailError.state = null;
  }

  void updateAddress(String value) {
    checkoutAddress.state = value;
    checkoutAddressError.state = null;
  }

  void updateNote(String value) => checkoutNote.state = value;

  void toggleShowName(bool value) => checkoutShowName.state = value;

  void togglePrivacy(bool value) {
    checkoutPrivacyAccepted.state = value;
    if (value) checkoutPrivacyError.state = null;
  }

  void submit(BuildContext context) {
    if (cartItems.state.isEmpty) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Tambahkan produk ke keranjang sebelum checkout.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    checkoutNameError.state = checkoutName.state.trim().isEmpty
        ? 'Nama penerima wajib diisi.'
        : null;
    checkoutWhatsappError.state =
        checkoutWhatsapp.state.replaceAll(RegExp(r'\D'), '').length < 8
        ? 'Masukkan nomor WhatsApp yang valid.'
        : null;
    checkoutEmailError.state =
        RegExp(
          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
        ).hasMatch(checkoutEmail.state.trim())
        ? null
        : 'Masukkan alamat email yang valid.';
    checkoutAddressError.state = checkoutAddress.state.trim().length < 6
        ? 'Masukkan alamat lengkap.'
        : null;
    checkoutPrivacyError.state = checkoutPrivacyAccepted.state
        ? null
        : 'Persetujuan Kebijakan Privasi wajib dicentang.';

    if (checkoutNameError.state != null ||
        checkoutWhatsappError.state != null ||
        checkoutEmailError.state != null ||
        checkoutAddressError.state != null ||
        checkoutPrivacyError.state != null) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali data penerima yang ditandai.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    checkoutForm.submit(() async {
      try {
        final orderCode = await SeeraSupabase.createOrder(
          customerName: checkoutName.state.trim(),
          whatsapp: checkoutWhatsapp.state,
          email: checkoutEmail.state.trim(),
          address: checkoutAddress.state.trim(),
          shipping: checkoutShipping,
          uniqueCode: checkoutUniqueCode,
          total: checkoutTotal,
          items: cartItems.state,
        );
        paymentOrderCode.state = orderCode.toString();
        nav.to('/payment');
      } catch (error) {
        if (!context.mounted) return;
        RM.scaffold.context = context;
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text('Pesanan gagal disimpan: $error'),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    });
  }
}
