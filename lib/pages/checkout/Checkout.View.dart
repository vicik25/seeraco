import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/order_progress_stepper.dart';
import '../cart/Cart.Data.dart';
import 'Checkout.Ctrl.dart';
import 'Checkout.Data.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  static const _controller = CheckoutCtrl();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Checkout',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 1120 ? screenWidth : 1120,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [const OrderProgressStepper(activeStep: 0), const SizedBox(height: 24), const _CheckoutContent()],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 50,
          child: OnFormSubmissionBuilder(
            listenTo: checkoutForm,
            onSubmitting: () => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: SeeraColors.pinkPop),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: SeeraColors.pinkPop),
              onPressed: () => _controller.submit(context),
              child: const Text(
                'Buat Pesanan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final form = const _CheckoutForm();
        final summary = const _CheckoutSummary();
        if (constraints.maxWidth >= 920) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: form),
              const SizedBox(width: 24),
              Expanded(child: summary),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [form, const SizedBox(height: 24), summary],
        );
      },
    );
  }
}

class _CheckoutForm extends StatelessWidget {
  const _CheckoutForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Data Penerima',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SeeraColors.ink),
        ),
        const SizedBox(height: 16),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-name'),
            initialValue: checkoutName.state,
            onChanged: _CheckoutForm.controller.updateName,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('Nama Lengkap', checkoutNameError.state),
          ),
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-whatsapp'),
            initialValue: checkoutWhatsapp.state,
            onChanged: _CheckoutForm.controller.updateWhatsapp,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Nomor WhatsApp', checkoutWhatsappError.state).copyWith(prefixText: '+62 '),
          ),
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-email'),
            initialValue: checkoutEmail.state,
            onChanged: _CheckoutForm.controller.updateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email', checkoutEmailError.state),
          ),
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-address'),
            initialValue: checkoutAddress.state,
            onChanged: _CheckoutForm.controller.updateAddress,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            decoration: _inputDecoration('Alamat Lengkap', checkoutAddressError.state),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: checkoutNote.state,
          onChanged: _CheckoutForm.controller.updateNote,
          maxLines: 2,
          decoration: _inputDecoration('Catatan untuk penjual (opsional)'),
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checkoutShowName.state,
            onChanged: (value) => _CheckoutForm.controller.toggleShowName(value ?? false),
            title: const Text('Tampilkan namaku (disamarkan) di daftar pembeli'),
            dense: true,
          ),
        ),
        OnReactive(
          () => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checkoutPrivacyAccepted.state,
            onChanged: (value) => _CheckoutForm.controller.togglePrivacy(value ?? false),
            title: const Text('Saya menyetujui Kebijakan Privasi (wajib)'),
            subtitle: checkoutPrivacyError.state == null
                ? null
                : Text(checkoutPrivacyError.state!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            dense: true,
          ),
        ),
        const SizedBox(height: 12),
        const _CheckoutPolicyNotes(),
      ],
    );
  }

  static const controller = CheckoutCtrl();
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ringkasan Pesanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SeeraColors.ink),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SeeraColors.pinkSoft),
          ),
          child: OnReactive(() {
            final items = cartItems.state;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (items.isEmpty)
                  const Text('Keranjangmu masih kosong.')
                else
                  for (final item in items) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} · ${item.variant} × ${item.quantity}',
                            style: const TextStyle(color: SeeraColors.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                const Divider(height: 20),
                _CheckoutCostLine(label: 'Subtotal', amount: checkoutSubtotal),
                const SizedBox(height: 8),
                _CheckoutCostLine(label: 'Ongkos kirim', amount: checkoutShipping),
                const SizedBox(height: 8),
                _CheckoutCostLine(label: 'Kode unik', amount: checkoutUniqueCode),
                const Divider(height: 20),
                _CheckoutCostLine(label: 'Total bayar', amount: checkoutTotal, emphasized: true),
                const SizedBox(height: 12),
                const Text(
                  'Estimasi tiba 3 sampai 5 hari setelah pembayaran dikonfirmasi.',
                  style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _CheckoutCostLine extends StatelessWidget {
  const _CheckoutCostLine({required this.label, required this.amount, this.emphasized = false});

  final String label;
  final int amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasized ? SeeraColors.pinkDeep : SeeraColors.ink,
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.normal,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(_formatCheckoutPrice(amount), style: style),
      ],
    );
  }
}

class _CheckoutPolicyNotes extends StatelessWidget {
  const _CheckoutPolicyNotes();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CheckoutNote(
          icon: Icons.schedule_outlined,
          text:
              'Bayar maksimal 24 jam setelah pesan ya. Kalau lewat, pesanan otomatis dibatalkan dan stoknya kami lepas.',
        ),
        const SizedBox(height: 8),
        _CheckoutNote(
          icon: Icons.local_shipping_outlined,
          text: 'Produk ini pre-order. Estimasi tiba 3 sampai 5 hari.',
        ),
      ],
    );
  }
}

class _CheckoutNote extends StatelessWidget {
  const _CheckoutNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SeeraColors.pinkDeep, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: SeeraColors.ink, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, [String? error]) {
  return InputDecoration(
    labelText: label,
    errorText: error,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

String _formatCheckoutPrice(int amount) {
  final formatted = amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return 'Rp$formatted';
}
