import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_supabase.dart';
import '../../domains/_models/cart_item.dart';
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
        final orderItems = List<CartItem>.unmodifiable(cartItems.state);
        final customerName = checkoutName.state.trim();
        final customerWhatsapp = checkoutWhatsapp.state;
        final customerAddress = checkoutAddress.state.trim();
        final orderSubtotal = checkoutSubtotal;
        final orderTotal =
            orderSubtotal + checkoutShipping + checkoutUniqueCode;
        final orderCode = await SeeraSupabase.createOrder(
          customerName: customerName,
          whatsapp: customerWhatsapp,
          email: checkoutEmail.state.trim(),
          address: customerAddress,
          note: checkoutNote.state.trim(),
          showNameInBuyerList: checkoutShowName.state,
          shipping: checkoutShipping,
          uniqueCode: checkoutUniqueCode,
          total: orderTotal,
          items: orderItems,
        );
        paymentOrderCode.state = orderCode.toString();
        paymentOrderItems.state = orderItems;
        paymentCustomerName.state = customerName;
        paymentCustomerWhatsapp.state = customerWhatsapp;
        paymentCustomerAddress.state = customerAddress;
        paymentOrderSubtotal.state = orderSubtotal;
        paymentOrderShipping.state = checkoutShipping;
        paymentProofFile.state = null;
        paymentProofSelected.state = false;
        _resetCheckoutDraft();
        nav.to('/payment');
      } catch (_) {
        if (!context.mounted) return;
        RM.scaffold.context = context;
        RM.scaffold.showSnackBar(
          SnackBar(
            content: const Text(
              'Pesanan gagal disimpan. Periksa koneksi lalu coba lagi.',
            ),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    });
  }

  void _resetCheckoutDraft() {
    cartItems.state = const [];
    checkoutName.state = '';
    checkoutWhatsapp.state = '';
    checkoutEmail.state = '';
    checkoutAddress.state = '';
    checkoutNote.state = '';
    checkoutShowName.state = false;
    checkoutPrivacyAccepted.state = false;
    checkoutNameError.state = null;
    checkoutWhatsappError.state = null;
    checkoutEmailError.state = null;
    checkoutAddressError.state = null;
    checkoutPrivacyError.state = null;
  }
}
