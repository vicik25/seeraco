import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../order_track/OrderTrack.Data.dart';
import 'Review.Ctrl.dart';
import 'Review.Data.dart';

class ReviewView extends StatelessWidget {
  const ReviewView({super.key});

  static const _controller = ReviewCtrl();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
        title: const Text(
          'Tulis Ulasan',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 600 ? screenWidth : 600,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              OnReactive(() {
                if (!orderTrackCompleted.state) return const _ReviewUnavailableBanner();
                return Column(
                  children: [
                    const _CompletedOrderBanner(),
                    const SizedBox(height: 16),
                    OnBuilder(
                      listenTo: reviewProducts,
                      builder: () {
                        final products = reviewProducts.state;
                        return Column(
                          children: [
                            for (var index = 0; index < products.length; index++) ...[
                              if (index > 0) const SizedBox(height: 12),
                              OnBuilder(
                                listenTo: reviewRatings,
                                builder: () => _ProductRatingCard(
                                  product: products[index],
                                  productIndex: index,
                                  rating: reviewRatings.state[index],
                                  onRatingChanged: _controller.selectRating,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const _ReviewTextCard(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ReviewBottomBar(onSubmit: () => _controller.submit(context)),
    );
  }
}

class _CompletedOrderBanner extends StatelessWidget {
  const _CompletedOrderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: SeeraColors.skyPastel, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.check_rounded, color: SeeraColors.pinkDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesanan selesai',
                  style: TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                OnReactive(
                  () => Text(
                    'Kode ${orderTrackCode.state} · Bagikan ceritamu tentang pesanan ini.',
                    style: const TextStyle(color: SeeraColors.ink, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewUnavailableBanner extends StatelessWidget {
  const _ReviewUnavailableBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: SeeraColors.pinkDeep),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ulasan hanya bisa ditulis setelah pesanan selesai.',
              style: TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRatingCard extends StatelessWidget {
  const _ProductRatingCard({
    required this.product,
    required this.productIndex,
    required this.rating,
    required this.onRatingChanged,
  });

  final String product;
  final int productIndex;
  final int rating;
  final void Function(int productIndex, int rating) onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUK YANG KAMU BELI',
            style: TextStyle(
              color: SeeraColors.greyMauve,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product,
            style: const TextStyle(color: SeeraColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Seberapa suka kamu dengan produk ini?',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 0,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                Semantics(
                  button: true,
                  label: 'Beri rating $star dari 5',
                  child: IconButton(
                    onPressed: () => onRatingChanged(productIndex, star),
                    tooltip: 'Beri rating $star dari 5',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                    icon: AnimatedScale(
                      scale: star <= rating ? 1.14 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: star <= rating ? SeeraColors.pinkPop : SeeraColors.pinkSoft,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              if (rating > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    '$rating/5',
                    style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTextCard extends StatelessWidget {
  const _ReviewTextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ceritakan pengalamanmu',
            style: TextStyle(color: SeeraColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: reviewText.state,
            maxLength: reviewTextMaxLength,
            maxLines: 5,
            onChanged: ReviewCtrl().updateReview,
            decoration: InputDecoration(
              hintText: 'Apa yang paling kamu suka dari pesanan ini?',
              filled: true,
              fillColor: SeeraColors.pinkMist,
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
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Foto tidak diperlukan untuk ulasan ini.',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ReviewBottomBar extends StatelessWidget {
  const _ReviewBottomBar({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SeeraColors.pinkSoft)),
      ),
      child: SizedBox(
        height: 50,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: OnFormSubmissionBuilder(
                listenTo: reviewForm,
                onSubmitting: () => const _SubmitReviewButton(isLoading: true),
                child: OnReactive(() => _SubmitReviewButton(onPressed: orderTrackCompleted.state ? onSubmit : null)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitReviewButton extends StatelessWidget {
  const _SubmitReviewButton({this.onPressed, this.isLoading = false});

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
      child: isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Kirim Ulasan', style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
