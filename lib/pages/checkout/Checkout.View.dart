import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/seera_checkout_step_indicator.dart';
import '../../core/widgets/seera_pill_button.dart';
import '../cart/Cart.Data.dart';
import 'Checkout.Ctrl.dart';
import 'Checkout.Data.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  static const _controller = CheckoutCtrl();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Nunito'),
      ),
      child: Scaffold(
        backgroundColor: SeeraColors.pinkMist,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: SeeraColors.pinkDeep,
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: SeeraColors.pinkDeep,
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => RM.navigate.back(),
          ),
        ),
        body: Center(
          child: SizedBox(
            width: screenWidth < 1120 ? screenWidth : 1120,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SeeraCheckoutStepIndicator(activeStep: 0),
                const SizedBox(height: 24),
                const _CheckoutContent(),
              ],
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeeraColors.pinkDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 48),
                  shape: const StadiumBorder(),
                ),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
              child: SeeraPillButton(
                label: 'Buat Pesanan',
                icon: Icons.lock_outline_rounded,
                onPressed: () => _controller.submit(context),
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
        const summary = _CheckoutSummary();
        if (constraints.maxWidth >= 920) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _CheckoutPanel(child: form)),
              const SizedBox(width: 24),
              Expanded(child: summary),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CheckoutPanel(child: form),
            const SizedBox(height: 24),
            summary,
          ],
        );
      },
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [
        BoxShadow(
          color: SeeraColors.pinkShadow,
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    ),
  );
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SeeraColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-name'),
            initialValue: checkoutName.state,
            onChanged: _CheckoutForm.controller.updateName,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              'Nama Lengkap',
              checkoutNameError.state,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OnReactive(
          () => TextFormField(
            key: const ValueKey('checkout-whatsapp'),
            initialValue: checkoutWhatsapp.state,
            onChanged: _CheckoutForm.controller.updateWhatsapp,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              'Nomor WhatsApp',
              checkoutWhatsappError.state,
            ).copyWith(prefixText: '+62 '),
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
            decoration: _inputDecoration(
              'Alamat Lengkap',
              checkoutAddressError.state,
            ),
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
            value: checkoutPrivacyAccepted.state,
            onChanged: (value) =>
                _CheckoutForm.controller.togglePrivacy(value ?? false),
            title: const Text('Saya menyetujui Kebijakan Privasi (wajib)'),
            subtitle: checkoutPrivacyError.state == null
                ? null
                : Text(
                    checkoutPrivacyError.state!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
            dense: true,
          ),
        ),
        OnReactive(
          () => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checkoutShowName.state,
            onChanged: (value) =>
                _CheckoutForm.controller.toggleShowName(value ?? false),
            title: const Text(
              'Tampilkan nama samaran dan barang yang dibeli di Pembeli Seera',
            ),
            subtitle: const Text(
              'Alamat, nomor WhatsApp, dan email tidak ditampilkan.',
            ),
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
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w800,
            color: SeeraColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: SeeraColors.pinkShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
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
                _CheckoutCostLine(
                  label: 'Ongkos kirim',
                  amount: checkoutShipping,
                ),
                const Divider(height: 20),
                _CheckoutCostLine(
                  label: 'Total bayar',
                  amount: checkoutTotal,
                  emphasized: true,
                ),
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
  const _CheckoutCostLine({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  final String label;
  final int amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasized ? SeeraColors.pinkDeep : SeeraColors.ink,
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.normal,
      fontFamily: emphasized ? 'Baloo2' : null,
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
        border: Border.all(color: SeeraColors.yellow),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SeeraColors.pinkDeep, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: SeeraColors.ink, height: 1.4),
            ),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: SeeraColors.pinkSoft),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: SeeraColors.pinkSoft),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: SeeraColors.pinkPop, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.red.shade700),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
    ),
  );
}

String _formatCheckoutPrice(int amount) {
  final formatted = amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp$formatted';
}
