import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../navigator.dart';
import '../cart/Cart.Data.dart';
import '../checkout/Checkout.Data.dart';
import 'OrderTrack.Ctrl.dart';
import 'OrderTrack.Data.dart';

class OrderTrackView extends StatelessWidget {
  const OrderTrackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.ink,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
        title: const Text(
          'Cek Pesanan',
          style: TextStyle(color: SeeraColors.pinkDeep, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
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
      bottomNavigationBar: _LookupBottomBar(onSubmit: () => OrderTrackCtrl().submit(context)),
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
            style: TextStyle(color: SeeraColors.ink, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Masukkan kode pesanan dan nomor WhatsApp yang digunakan saat checkout.',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 17),
          TextFormField(
            initialValue: orderTrackCode.state,
            onChanged: OrderTrackCtrl().updateCode,
            textCapitalization: TextCapitalization.characters,
            decoration: _inputDecoration(label: 'Kode Pesanan', hint: 'Contoh: SEERA-261013-001'),
          ),
          const SizedBox(height: 13),
          TextFormField(
            initialValue: orderTrackWhatsapp.state,
            onChanged: OrderTrackCtrl().updateWhatsapp,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(label: 'Nomor WhatsApp', hint: '812 3456 7890', prefixText: '+62 '),
          ),
          const SizedBox(height: 8),
          const Text(
            'Untuk simulasi ulasan pesanan selesai, gunakan SEERA-261012-004 dan nomor 81234567890.',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({required String label, required String hint, String? prefixText}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SeeraColors.pinkSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SeeraColors.pinkSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SeeraColors.pinkPop, width: 1.5),
      ),
    );
  }
}

class _LookupButton extends StatelessWidget {
  const _LookupButton({this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: SeeraColors.pinkPop,
        disabledBackgroundColor: SeeraColors.pinkPop.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Text(isLoading ? 'Mencari pesanan' : 'Cek Pesanan', style: const TextStyle(fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SeeraColors.pinkSoft)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: OnFormSubmissionBuilder(
              listenTo: orderTrackForm,
              onSubmitting: () => const _LookupButton(isLoading: true),
              child: _LookupButton(onPressed: onSubmit),
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
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Color(0xFFB3261E)),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Kode atau nomor tidak cocok, cek lagi ya.',
              style: TextStyle(color: Color(0xFF8B1E18), fontWeight: FontWeight.w700),
            ),
          ),
        ],
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
          () => _TrackCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ringkasan pesanan',
                        style: TextStyle(color: SeeraColors.ink, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    _StatusBadge(isCompleted: orderTrackCompleted.state),
                  ],
                ),
                const SizedBox(height: 15),
                _SummaryLine(label: 'Kode pesanan', value: orderTrackCode.state),
                const SizedBox(height: 9),
                const _SummaryLine(label: 'Tanggal pesanan', value: '13 Okt 2026'),
                const SizedBox(height: 9),
                _SummaryLine(label: 'Item', value: _trackedItemsSummary()),
                const SizedBox(height: 9),
                _SummaryLine(
                  label: 'Alamat',
                  value: checkoutAddress.state.isEmpty ? 'Alamat demo, Bandung' : checkoutAddress.state,
                ),
                const SizedBox(height: 9),
                _SummaryLine(label: 'Total', value: _formatTrackedPrice(checkoutTotal), isEmphasized: true),
                const SizedBox(height: 9),
                const _SummaryLine(label: 'Estimasi tiba', value: '3–5 hari setelah dikonfirmasi'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        OnReactive(() {
          final complete = orderTrackCompleted.state;
          return _TrackCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perjalanan pesanan',
                  style: TextStyle(color: SeeraColors.ink, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                const _TimelineEntry(
                  title: 'Pesanan dibuat',
                  time: '13 Okt 2026 · 10.32',
                  state: _TimelineState.done,
                  hasLine: true,
                ),
                const _TimelineEntry(
                  title: 'Bukti bayar diterima',
                  time: '13 Okt 2026 · 10.35',
                  state: _TimelineState.done,
                  hasLine: true,
                ),
                _TimelineEntry(
                  title: 'Diproses',
                  time: complete ? 'Pesanan sudah disiapkan' : '13 Okt 2026 · 11.10',
                  state: complete ? _TimelineState.done : _TimelineState.current,
                  hasLine: true,
                ),
                _TimelineEntry(
                  title: 'Selesai',
                  time: complete ? 'Pesanan diterima' : 'Menunggu pesanan tiba',
                  state: complete ? _TimelineState.current : _TimelineState.upcoming,
                  hasLine: false,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 14),
        OnReactive(
          () => _TrackCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_shipping_outlined, color: SeeraColors.pinkDeep),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    orderTrackCompleted.state
                        ? 'Pesanan ini telah selesai. Terima kasih sudah berbelanja bersama Seera!'
                        : 'Pesananmu sedang dicek dan disiapkan. Kami akan memperbarui status setelah pesanan siap dikirim.',
                    style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 13, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
        OnReactive(
          () => orderTrackCompleted.state
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: FilledButton.icon(
                    onPressed: () => nav.to('/review'),
                    style: FilledButton.styleFrom(
                      backgroundColor: SeeraColors.pinkPop,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Tulis Ulasan'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: SeeraColors.skyPastel, borderRadius: BorderRadius.circular(20)),
      child: Text(
        isCompleted ? 'Selesai' : 'Proses',
        style: TextStyle(color: SeeraColors.ink, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

String _trackedItemsSummary() {
  final items = cartItems.state;
  if (items.isEmpty) return 'Pastel Daisy Bracelet × 1';
  return items.map((item) => '${item.product.name} × ${item.quantity}').join(', ');
}

String _formatTrackedPrice(int amount) {
  final formatted = amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return 'Rp$formatted';
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, this.isEmphasized = false});

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 126,
          child: Text(label, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isEmphasized ? SeeraColors.pinkDeep : SeeraColors.ink,
              fontFamily: isEmphasized ? 'monospace' : null,
              fontSize: isEmphasized ? 14 : 12,
              fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

enum _TimelineState { done, current, upcoming }

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.title, required this.time, required this.state, required this.hasLine});

  final String title;
  final String time;
  final _TimelineState state;
  final bool hasLine;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _TimelineState.done => SeeraColors.pinkPop,
      _TimelineState.current => SeeraColors.pinkDeep,
      _TimelineState.upcoming => SeeraColors.pinkSoft,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state == _TimelineState.upcoming ? Colors.white : color,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: state == _TimelineState.done ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                ),
                if (hasLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: SeeraColors.pinkSoft,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: hasLine ? 18 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: state == _TimelineState.upcoming ? SeeraColors.greyMauve : SeeraColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(time, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
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
