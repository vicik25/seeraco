import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/order_progress_stepper.dart';
import '../../data/seera_supabase.dart';
import '../checkout/Checkout.Data.dart';
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
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: SeeraColors.pinkDeep,
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
              const OrderProgressStepper(activeStep: 1),
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
              _BankAccountCard(
                onCopy: () => _controller.copyText(
                  context,
                  currentPaymentAccountNumber,
                  'Nomor rekening',
                ),
              ),
              const SizedBox(height: 14),
              const _QrisCard(),
              const SizedBox(height: 14),
              const _ProofUploadCard(),
              const SizedBox(height: 14),
              const _KeepOrderCodeNote(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PaymentBottomBar(
        onSubmit: () => _controller.submit(context),
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
              color: SeeraColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
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
                  value: checkoutName.state.isEmpty
                      ? 'Pelanggan Seera'
                      : checkoutName.state,
                ),
                const SizedBox(height: 10),
                _RecipientLine(
                  label: 'WhatsApp',
                  value: checkoutWhatsapp.state.isEmpty
                      ? '+62'
                      : '+62 ${checkoutWhatsapp.state}',
                ),
                const SizedBox(height: 10),
                _RecipientLine(
                  label: 'Alamat',
                  value: checkoutAddress.state.isEmpty
                      ? 'Alamat belum diisi'
                      : checkoutAddress.state,
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
                  onPressed: () => PaymentCtrl().copyText(
                    context,
                    '$paymentTotal',
                    'Nominal pembayaran',
                  ),
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
            _PaymentCostLine(label: 'Ongkir', amount: checkoutShipping),
            const SizedBox(height: 8),
            _PaymentCostLine(label: 'Kode unik', amount: checkoutUniqueCode),
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
  const _PaymentCostLine({required this.label, required this.amount});
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: SeeraColors.ink)),
        ),
        Text(
          'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
          style: const TextStyle(
            color: SeeraColors.ink,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
          ),
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
            style: TextStyle(
              color: SeeraColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
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
  const _QrisCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bayar dengan QRIS',
            style: TextStyle(
              color: SeeraColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OnReactive(() {
            final qrisUrl = currentPaymentQrisUrl;
            return Center(
              child: qrisUrl.isEmpty
                  ? Image.asset(
                      'assets/images/qris.jpeg',
                      height: 240,
                      fit: BoxFit.contain,
                      semanticLabel: 'Kode QRIS Seera.co_',
                    )
                  : Image.network(
                      qrisUrl,
                      height: 240,
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
              child: Container(
                constraints: const BoxConstraints(minHeight: 116),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: SeeraColors.pinkPop, width: 2),
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
        ],
      ),
    );
  }
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
                  'Kirim Bukti Bayar',
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
