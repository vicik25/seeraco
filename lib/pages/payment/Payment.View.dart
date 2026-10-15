import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/order_progress_stepper.dart';
import '../checkout/Checkout.Data.dart';
import 'Payment.Ctrl.dart';
import 'Payment.Data.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  static const _controller = PaymentCtrl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const OrderProgressStepper(activeStep: 1),
              const SizedBox(height: 22),
              const _OrderCreatedCard(),
              const SizedBox(height: 14),
              const _PaymentAmountCard(),
              const SizedBox(height: 14),
              const _PaymentRecipientCard(),
              const SizedBox(height: 14),
              _BankAccountCard(onCopy: () => _controller.copyText(context, paymentAccountNumber, 'Nomor rekening')),
              const SizedBox(height: 14),
              const _ProofUploadCard(),
              const SizedBox(height: 14),
              const _KeepOrderCodeNote(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PaymentBottomBar(onSubmit: () => _controller.submit(context)),
    );
  }
}

class _OrderCreatedCard extends StatelessWidget {
  const _OrderCreatedCard();

  @override
  Widget build(BuildContext context) {
    return const _PaymentCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: SeeraColors.pinkSoft,
            child: Icon(Icons.check_rounded, color: SeeraColors.pinkDeep, size: 32),
          ),
          SizedBox(height: 12),
          Text(
            'Pesananmu sudah dibuat!',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.ink, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            'KODE PESANAN',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 5),
          _CopyOrderCode(),
          SizedBox(height: 12),
          _CountdownBadge(),
        ],
      ),
    );
  }
}

class _PaymentRecipientCard extends StatelessWidget {
  const _PaymentRecipientCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Data penerima',
            style: TextStyle(color: SeeraColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: checkoutName.state.isEmpty ? 'Pelanggan Seera' : checkoutName.state,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: checkoutWhatsapp.state.isEmpty ? '+62' : '+62 ${checkoutWhatsapp.state}',
            readOnly: true,
            decoration: const InputDecoration(labelText: 'WhatsApp'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: checkoutAddress.state.isEmpty ? 'Alamat belum diisi' : checkoutAddress.state,
            readOnly: true,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Alamat'),
          ),
        ],
      ),
    );
  }
}

class _CopyOrderCode extends StatelessWidget {
  const _CopyOrderCode();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const SelectableText(
          paymentOrderCode,
          style: TextStyle(
            color: SeeraColors.pinkDeep,
            fontFamily: 'monospace',
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          tooltip: 'Salin kode pesanan',
          visualDensity: VisualDensity.compact,
          onPressed: () => PaymentCtrl().copyText(context, paymentOrderCode, 'Kode pesanan'),
          icon: const Icon(Icons.copy_rounded, size: 18),
          color: SeeraColors.pinkDeep,
        ),
      ],
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: SeeraColors.creamPaper, borderRadius: BorderRadius.circular(20)),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 17, color: SeeraColors.pinkDeep),
          const SizedBox(width: 7),
          OnReactive(() {
            final remaining = paymentCountdown.state.inSeconds.clamp(0, const Duration(hours: 24).inSeconds).toInt();
            final hours = remaining ~/ 3600;
            final minutes = remaining ~/ 60 % 60;
            final timer =
                '${hours.toString().padLeft(2, '0')}:'
                '${minutes.toString().padLeft(2, '0')}';
            return Text(
              'Selesaikan pembayaran dalam $timer',
              style: const TextStyle(color: SeeraColors.ink, fontSize: 12, fontWeight: FontWeight.w700),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentAmountCard extends StatelessWidget {
  const _PaymentAmountCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      color: SeeraColors.pinkLocker,
      child: OnReactive(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TRANSFER TEPAT SEBESAR',
              style: TextStyle(
                color: SeeraColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatPaymentAmount(paymentTotal),
                      style: const TextStyle(
                        color: SeeraColors.ink,
                        fontFamily: 'monospace',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Salin nominal pembayaran',
                  onPressed: () => PaymentCtrl().copyText(context, '$paymentTotal', 'Nominal pembayaran'),
                  icon: const Icon(Icons.copy_rounded),
                  color: SeeraColors.ink,
                ),
              ],
            ),
            const Text(
              'Transfer sesuai nominal sampai tiga digit terakhir.',
              style: TextStyle(color: SeeraColors.ink, fontSize: 12),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: SeeraColors.pinkSoft),
            ),
            _PaymentCostLine(label: 'Subtotal', amount: checkoutSubtotal),
            const SizedBox(height: 8),
            const _PaymentCostLine(label: 'Ongkir', amount: checkoutShipping),
            const SizedBox(height: 8),
            const _PaymentCostLine(label: 'Kode unik', amount: checkoutUniqueCode),
          ],
        ),
      ),
    );
  }
}

String _formatPaymentAmount(int amount) {
  final formatted = amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp$formatted';
}

class _PaymentCostLine extends StatelessWidget {
  const _PaymentCostLine({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final formatted = amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: SeeraColors.ink)),
        ),
        Text(
          'Rp$formatted',
          style: const TextStyle(color: SeeraColors.ink, fontFamily: 'monospace', fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Transfer Bank',
            style: TextStyle(color: SeeraColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 54,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: SeeraColors.skyPastel, borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'BCA',
                  style: TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paymentBankName, style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                    SizedBox(height: 3),
                    Text(
                      paymentAccountNumber,
                      style: TextStyle(
                        color: SeeraColors.ink,
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text('a.n. $paymentAccountHolder', style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Salin nomor rekening',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
                color: SeeraColors.pinkDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProofUploadCard extends StatelessWidget {
  const _ProofUploadCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Unggah bukti bayar',
            style: TextStyle(color: SeeraColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          OnReactive(
            () => InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: PaymentCtrl().selectProof,
              child: CustomPaint(
                painter: _DashedBorderPainter(color: SeeraColors.pinkPop, radius: 12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 116),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paymentProofSelected.state ? Icons.image_outlined : Icons.add_photo_alternate_outlined,
                        color: SeeraColors.pinkDeep,
                        size: 28,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        paymentProofSelected.state ? paymentProofFileName : 'Ketuk untuk pilih foto bukti bayar',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        paymentProofSelected.state ? 'Foto bukti transfer siap dikirim' : 'JPG atau PNG, maksimal 5 MB',
                        style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Simulasi: ketuk area di atas untuk memilih bukti transfer.',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 7).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _KeepOrderCodeNote extends StatelessWidget {
  const _KeepOrderCodeNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline, color: SeeraColors.pinkDeep, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Simpan kode pesananmu untuk cek status kapan saja.',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.child, this.color = Colors.white});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  const _PaymentBottomBar({required this.onSubmit});

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
            width: double.infinity,
            height: 50,
            child: OnFormSubmissionBuilder(
              listenTo: paymentForm,
              onSubmitting: () => const _SubmitPaymentButton(isLoading: true),
              child: _SubmitPaymentButton(onPressed: onSubmit),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitPaymentButton extends StatelessWidget {
  const _SubmitPaymentButton({this.onPressed, this.isLoading = false});

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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            isLoading ? 'Mengirim bukti bayar' : 'Kirim Bukti Bayar',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
