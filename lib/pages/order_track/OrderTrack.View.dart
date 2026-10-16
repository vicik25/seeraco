import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/order_progress_stepper.dart';
import '../../navigator.dart';
import '../cart/Cart.Data.dart';
import '../checkout/Checkout.Data.dart';
import 'OrderTrack.Ctrl.dart';
import 'OrderTrack.Data.dart';

class OrderTrackView extends StatelessWidget {
  const OrderTrackView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.ink,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => RM.navigate.back(),
        ),
        title: const Text(
          'Cek Pesanan',
          style: TextStyle(
            color: SeeraColors.pinkDeep,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 600 ? screenWidth : 600,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _LookupForm(),
              const SizedBox(height: 18),
              OnReactive(() {
                if (!orderTrackHasSearched.state) {
                  return const SizedBox.shrink();
                }
                if (!orderTrackHasMatch.state) {
                  return const _LookupError();
                }
                return const _OrderStatusResult();
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _LookupBottomBar(
        onSubmit: () => OrderTrackCtrl().submit(context),
      ),
    );
  }
}

class _LookupForm extends StatelessWidget {
  const _LookupForm();

  @override
  Widget build(BuildContext context) {
    return _TrackCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Lacak pesananmu',
            style: TextStyle(
              color: SeeraColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
          TextFormField(
            initialValue: orderTrackCode.state,
            onChanged: OrderTrackCtrl().updateCode,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Kode Pesanan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 13),
          TextFormField(
            initialValue: orderTrackWhatsapp.state,
            onChanged: OrderTrackCtrl().updateWhatsapp,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor WhatsApp',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LookupBottomBar extends StatelessWidget {
  const _LookupBottomBar({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 600,
            height: 50,
            child: OnFormSubmissionBuilder(
              listenTo: orderTrackForm,
              onSubmitting: () => ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeeraColors.pinkPop,
                ),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeeraColors.pinkPop,
                ),
                child: const Text(
                  'Cek Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LookupError extends StatelessWidget {
  const _LookupError();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        border: Border.all(color: const Color(0xFFE7A5A5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Kode atau nomor tidak cocok, cek lagi ya.',
        style: TextStyle(color: Color(0xFF8B1E18), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _OrderStatusResult extends StatelessWidget {
  const _OrderStatusResult();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnReactive(
          () => OrderProgressStepper(
            activeStep: orderTrackCompleted.state ? 2 : 1,
          ),
        ),
        const SizedBox(height: 14),
        const _OrderStatusBanner(),
        const SizedBox(height: 14),
        OnReactive(
          () => _TrackCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan pesanan',
                  style: TextStyle(
                    color: SeeraColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                _SummaryLine(
                  label: 'Kode pesanan',
                  value: orderTrackCode.state,
                ),
                const SizedBox(height: 9),
                _SummaryLine(
                  label: 'Item',
                  value: orderTrackItems.state.isEmpty
                      ? (cartItems.state.isEmpty
                            ? 'Item'
                            : cartItems.state
                                  .map((e) => e.product.name)
                                  .join(', '))
                      : orderTrackItems.state
                            .map(
                              (item) =>
                                  '${item.product.name} × ${item.quantity}',
                            )
                            .join(', '),
                ),
                const SizedBox(height: 9),
                _SummaryLine(
                  label: 'Alamat',
                  value: orderTrackAddress.state.isEmpty
                      ? (checkoutAddress.state.isEmpty
                            ? 'Belum diisi'
                            : checkoutAddress.state)
                      : orderTrackAddress.state,
                ),
                const SizedBox(height: 9),
                _SummaryLine(
                  label: 'Total',
                  value: _formatTrackedPrice(
                    orderTrackTotal.state > 0
                        ? orderTrackTotal.state
                        : checkoutTotal,
                  ),
                  isEmphasized: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        OnReactive(
          () => orderTrackCompleted.state
              ? ElevatedButton(
                  onPressed: () => nav.to('/review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SeeraColors.pinkPop,
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text(
                    'Tulis Ulasan',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _OrderStatusBanner extends StatelessWidget {
  const _OrderStatusBanner();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      final completed = orderTrackCompleted.state;
      final color = completed ? const Color(0xFFE5F4E8) : SeeraColors.skyPastel;
      final status = orderTrackStatus.state.isEmpty
          ? 'Menunggu pembayaran'
          : orderTrackStatus.state;
      final displayStatus = status == 'Proses'
          ? 'Proses · Bukti bayar diterima'
          : status;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle_outline
                  : Icons.hourglass_top_rounded,
              color: SeeraColors.ink,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayStatus,
                    style: const TextStyle(
                      color: SeeraColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    completed
                        ? 'Pesananmu sudah sampai. Terima kasih ya, boleh tulis ulasan?'
                        : 'Pesananmu sedang kami cek dan siapkan.',
                    style: const TextStyle(
                      color: SeeraColors.ink,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

String _formatTrackedPrice(int amount) {
  return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });
  final String label;
  final String value;
  final bool isEmphasized;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isEmphasized ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
