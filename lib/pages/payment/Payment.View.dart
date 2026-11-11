import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/theme/seera_theme.dart';
import '../../core/widgets/seera_checkout_step_indicator.dart';
import '../../core/widgets/seera_pill_button.dart';
import '../../data/seera_supabase.dart';
import 'Payment.Ctrl.dart';
import 'Payment.Data.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  static const _controller = PaymentCtrl();

  @override
  void initState() {
    super.initState();
    _loadStoreSettings();
  }

  Future<void> _loadStoreSettings() async {
    storePaymentSettingsError.state = null;
    try {
      storePaymentSettings.state = await SeeraSupabase.fetchStoreSettings();
    } catch (error) {
      storePaymentSettingsError.state = error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Theme(
      data: buildSeeraTheme().copyWith(
        textTheme: buildSeeraTheme().textTheme.apply(fontFamily: 'Nunito'),
      ),
      child: Scaffold(
        backgroundColor: SeeraColors.pinkMist,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: SeeraColors.pinkDeep,
          title: const Text(
            'Pembayaran',
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
            width: screenWidth < 600 ? screenWidth : 600,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SeeraCheckoutStepIndicator(activeStep: 1),
                const SizedBox(height: 22),
                const _OrderCreatedCard(),
                const SizedBox(height: 14),
                const _PaymentAmountCard(),
                OnReactive(
                  () => storePaymentSettingsError.state == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            'Informasi rekening toko belum dapat dimuat.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                const _PaymentRecipientCard(),
                const SizedBox(height: 14),
                _PaymentMethodCards(
                  onCopy: () => _controller.copyText(
                    context,
                    currentPaymentAccountNumber,
                    'Nomor rekening',
                  ),
                ),
                const SizedBox(height: 14),
                const _ProofUploadCard(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _PaymentBottomBar(
          onSubmit: () => _controller.submit(context),
        ),
      ),
    );
  }
}

class _OrderCreatedCard extends StatelessWidget {
  const _OrderCreatedCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: SeeraColors.pinkSoft,
            child: Icon(
              Icons.check_rounded,
              color: SeeraColors.pinkDeep,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pesananmu sudah dibuat!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SeeraColors.pinkDeep,
              fontFamily: 'Baloo2',
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'KODE PESANAN',
            style: TextStyle(
              color: SeeraColors.greyMauve,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          const _CopyOrderCode(),
          const SizedBox(height: 12),
          const _KeepOrderCodeNote(),
          const SizedBox(height: 12),
          const _CountdownBadge(),
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
            style: TextStyle(
              color: SeeraColors.ink,
              fontFamily: 'Baloo2',
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OnReactive(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RecipientLine(
                  label: 'Nama',
                  value: paymentCustomerName.state.isEmpty
                      ? 'Pelanggan Seera'
                      : paymentCustomerName.state,
                ),
                const SizedBox(height: 10),
                _RecipientLine(
                  label: 'WhatsApp',
                  value: paymentCustomerWhatsapp.state.isEmpty
                      ? '+62'
                      : '+62 ${paymentCustomerWhatsapp.state}',
                ),
                const SizedBox(height: 10),
                _RecipientLine(
                  label: 'Alamat',
                  value: paymentCustomerAddress.state.isEmpty
                      ? 'Alamat belum diisi'
                      : paymentCustomerAddress.state,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientLine extends StatelessWidget {
  const _RecipientLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: SeeraColors.ink)),
      ],
    );
  }
}

class _CopyOrderCode extends StatelessWidget {
  const _CopyOrderCode();

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SelectableText(
            paymentOrderCode.state,
            style: const TextStyle(
              color: SeeraColors.pinkDeep,
              fontFamily: 'monospace',
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            tooltip: 'Salin kode pesanan',
            visualDensity: VisualDensity.compact,
            onPressed: () => PaymentCtrl().copyText(
              context,
              paymentOrderCode.state,
              'Kode pesanan',
            ),
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: SeeraColors.pinkDeep,
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 17,
            color: SeeraColors.pinkDeep,
          ),
          const SizedBox(width: 7),
          OnReactive(() {
            final remaining = paymentCountdown.state.inSeconds
                .clamp(0, const Duration(hours: 24).inSeconds)
                .toInt();
            final hours = remaining ~/ 3600;
            final minutes = remaining ~/ 60 % 60;
            return Text(
              'Selesaikan pembayaran dalam ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: SeeraColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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
      gradient: const LinearGradient(
        colors: [SeeraColors.pinkHeroStart, SeeraColors.pinkHeroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: OnReactive(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TRANSFER TEPAT SEBESAR',
              style: TextStyle(
                color: Colors.white,
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
                        color: Colors.white,
                        fontFamily: 'Baloo2',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => PaymentCtrl().copyText(
                    context,
                    '$paymentTotal',
                    'Nominal pembayaran',
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  color: Colors.white,
                ),
              ],
            ),
            const Text(
              'Transfer sesuai total tagihan yang tertera.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0x66FFFFFF)),
            ),
            _PaymentCostLine(
              label: 'Subtotal',
              amount: paymentOrderSubtotal.state,
              onGradient: true,
            ),
            const SizedBox(height: 8),
            _PaymentCostLine(
              label: 'Ongkir',
              amount: paymentOrderShipping.state,
              onGradient: true,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPaymentAmount(int amount) {
  return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

class _PaymentCostLine extends StatelessWidget {
  const _PaymentCostLine({
    required this.label,
    required this.amount,
    this.onGradient = false,
  });
  final String label;
  final int amount;
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    final foreground = onGradient ? Colors.white : SeeraColors.ink;
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: foreground)),
        ),
        Text(
          'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
          style: TextStyle(
            color: foreground,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({
    required this.onCopy,
    required this.selected,
    required this.onSelect,
  });

  final VoidCallback onCopy;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      selected: selected,
      onTap: onSelect,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transfer Bank',
                  style: TextStyle(
                    color: SeeraColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: SeeraColors.pinkPop),
            ],
          ),
          const SizedBox(height: 12),
          OnReactive(
            () => Row(
              children: [
                Container(
                  width: 72,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SeeraColors.skyPastel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentPaymentBankName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SeeraColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPaymentBankName,
                        style: const TextStyle(
                          color: SeeraColors.greyMauve,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      currentPaymentAccountNumber.isEmpty
                          ? const Text(
                              'Nomor rekening belum diatur',
                              style: TextStyle(color: SeeraColors.greyMauve),
                            )
                          : SelectableText(
                              currentPaymentAccountNumber,
                              style: const TextStyle(
                                color: SeeraColors.ink,
                                fontFamily: 'monospace',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                      const SizedBox(height: 3),
                      Text(
                        'a.n. $paymentAccountHolder',
                        style: const TextStyle(
                          color: SeeraColors.greyMauve,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded),
                  color: SeeraColors.pinkDeep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrisCard extends StatelessWidget {
  const _QrisCard({required this.selected, required this.onSelect});

  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      selected: selected,
      onTap: onSelect,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bayar dengan QRIS',
                  style: TextStyle(
                    color: SeeraColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: SeeraColors.pinkPop),
            ],
          ),
          const SizedBox(height: 12),
          OnReactive(() {
            final qrisUrl = currentPaymentQrisUrl;
            return Center(
              child: qrisUrl.isEmpty
                  ? Image.asset(
                      'assets/images/qris.jpeg',
                      height: 180,
                      fit: BoxFit.contain,
                      semanticLabel: 'Kode QRIS Seera.co_',
                    )
                  : Image.network(
                      qrisUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      semanticLabel: 'Kode QRIS Seera.co_',
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Gambar QRIS tidak dapat dimuat.'),
                    ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Pindai kode QR dengan aplikasi pembayaran pilihanmu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCards extends StatefulWidget {
  const _PaymentMethodCards({required this.onCopy});

  final VoidCallback onCopy;

  @override
  State<_PaymentMethodCards> createState() => _PaymentMethodCardsState();
}

class _PaymentMethodCardsState extends State<_PaymentMethodCards> {
  var _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bankCard = _BankAccountCard(
          onCopy: widget.onCopy,
          selected: _selectedMethod == 0,
          onSelect: () => setState(() => _selectedMethod = 0),
        );
        final qrisCard = _QrisCard(
          selected: _selectedMethod == 1,
          onSelect: () => setState(() => _selectedMethod = 1),
        );
        final wide = constraints.maxWidth >= 760;
        if (!wide) {
          return Column(
            children: [bankCard, const SizedBox(height: 14), qrisCard],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: bankCard),
            const SizedBox(width: 14),
            Expanded(child: qrisCard),
          ],
        );
      },
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
            style: TextStyle(
              color: SeeraColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OnReactive(
            () => InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => PaymentCtrl().selectProof(context),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: SeeraColors.pinkPop,
                  radius: 12,
                ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 116),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paymentProofSelected.state
                            ? Icons.image_outlined
                            : Icons.add_photo_alternate_outlined,
                        color: SeeraColors.pinkDeep,
                        size: 28,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        paymentProofSelected.state
                            ? paymentProofFile.state?.name ?? 'Foto dipilih'
                            : 'Ketuk untuk pilih foto bukti bayar',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: SeeraColors.pinkDeep,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        paymentProofSelected.state
                            ? 'Foto bukti transfer siap dikirim'
                            : 'JPG atau PNG, maksimal 5 MB',
                        style: const TextStyle(
                          color: SeeraColors.greyMauve,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepOrderCodeNote extends StatelessWidget {
  const _KeepOrderCodeNote();

  @override
  Widget build(BuildContext context) => OnReactive(
    () => Row(
      children: [
        const Icon(Icons.info_outline, color: SeeraColors.pinkDeep, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Simpan kode pesanan dan nomor WhatsApp ${paymentCustomerWhatsapp.state}. Keduanya diperlukan untuk cek pesanan.',
            style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: 'Salin nomor WhatsApp',
          onPressed: () => PaymentCtrl().copyText(
            context,
            paymentCustomerWhatsapp.state,
            'Nomor WhatsApp',
          ),
          icon: const Icon(Icons.copy_rounded, size: 18),
          color: SeeraColors.pinkDeep,
        ),
      ],
    ),
  );
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.child,
    this.gradient,
    this.selected = false,
    this.onTap,
  });

  final Widget child;
  final Gradient? gradient;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: gradient == null ? Colors.white : null,
            gradient: gradient,
            border: Border.all(
              color: selected ? SeeraColors.pinkPop : SeeraColors.pinkSoft,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: SeeraColors.pinkShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
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
      color: Colors.white,
      child: SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 600,
            height: 50,
            child: OnFormSubmissionBuilder(
              listenTo: paymentForm,
              onSubmitting: () => ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeeraColors.pinkDeep,
                  shape: const StadiumBorder(),
                ),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
              child: SeeraPillButton(
                label: 'Kirim Bukti Bayar',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onSubmit,
              ),
            ),
          ),
        ),
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
    final borderPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in borderPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 7).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
