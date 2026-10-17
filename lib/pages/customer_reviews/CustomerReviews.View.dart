import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../domains/_models/product_review.dart';
import 'CustomerReviews.Ctrl.dart';
import 'CustomerReviews.Data.dart';

class CustomerReviewsView extends StatefulWidget {
  const CustomerReviewsView({super.key});

  @override
  State<CustomerReviewsView> createState() => _CustomerReviewsViewState();
}

class _CustomerReviewsViewState extends State<CustomerReviewsView> {
  @override
  void initState() {
    super.initState();
    CustomerReviewsCtrl().loadReviews();
  }

  Future<void> _openReviewForm() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _WriteReviewSheet(
        onSubmit:
            ({required customerName, required rating, required comment}) =>
                CustomerReviewsCtrl().submitReview(
                  customerName: customerName,
                  rating: rating,
                  comment: comment,
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SeeraColors.pinkMist,
    appBar: AppBar(
      backgroundColor: SeeraColors.pinkSoft,
      foregroundColor: SeeraColors.pinkDeep,
      title: const Text(
        'Ulasan Pelanggan',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: OnReactive(() {
      final error = customerReviewsError.state;
      final reviews = customerReviews.state;
      return RefreshIndicator(
        onRefresh: CustomerReviewsCtrl().loadReviews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            const Text(
              'Cerita dari pelanggan Seera',
              style: TextStyle(
                color: SeeraColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Lihat pengalaman mereka dan bagikan ceritamu juga.',
              style: TextStyle(color: SeeraColors.greyMauve),
            ),
            const SizedBox(height: 20),
            if (isCustomerReviewsLoading.state && reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              _ReviewsError(
                message: error,
                onRetry: CustomerReviewsCtrl().loadReviews,
              )
            else if (reviews.isEmpty)
              const _ReviewsEmpty()
            else
              for (final review in reviews) ...[
                _ReviewCard(review: review),
                const SizedBox(height: 12),
              ],
          ],
        ),
      );
    }),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openReviewForm,
      backgroundColor: SeeraColors.pinkPop,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.rate_review_outlined),
      label: const Text('Tulis Ulasan'),
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: SeeraColors.pinkSoft,
                child: Text(
                  review.customerName.isEmpty
                      ? 'S'
                      : review.customerName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: SeeraColors.pinkDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  review.customerName.isEmpty
                      ? 'Pelanggan Seera'
                      : review.customerName,
                  style: const TextStyle(
                    color: SeeraColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _RatingStars(rating: review.rating),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(color: SeeraColors.ink, height: 1.45),
          ),
        ],
      ),
    ),
  );
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Rating $rating dari 5',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: star <= rating ? SeeraColors.pinkPop : SeeraColors.pinkSoft,
          ),
      ],
    ),
  );
}

class _ReviewsEmpty extends StatelessWidget {
  const _ReviewsEmpty();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        Icon(Icons.chat_bubble_outline, size: 40, color: SeeraColors.pinkDeep),
        SizedBox(height: 12),
        Text('Belum ada ulasan', style: TextStyle(fontWeight: FontWeight.w800)),
        SizedBox(height: 4),
        Text(
          'Jadilah pelanggan pertama yang berbagi cerita.',
          textAlign: TextAlign.center,
          style: TextStyle(color: SeeraColors.greyMauve),
        ),
      ],
    ),
  );
}

class _ReviewsError extends StatelessWidget {
  const _ReviewsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Ulasan tidak dapat dimuat: $message',
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Coba lagi'),
      ),
    ],
  );
}

typedef _ReviewSubmit =
    Future<void> Function({
      required String customerName,
      required int rating,
      required String comment,
    });

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.onSubmit});

  final _ReviewSubmit onSubmit;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  final _name = TextEditingController();
  final _comment = TextEditingController();
  var _rating = 0;
  var _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        customerName: _name.text,
        rating: _rating,
        comment: _comment.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil dikirim. Terima kasih!')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ceritakan pengalamanmu',
                style: TextStyle(
                  color: SeeraColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('customer-review-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Anda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Beri rating',
                style: TextStyle(
                  color: SeeraColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  for (var star = 1; star <= 5; star++)
                    IconButton(
                      key: ValueKey('customer-review-rating-$star'),
                      tooltip: 'Beri rating $star dari 5',
                      onPressed: () => setState(() {
                        _rating = star;
                        _error = null;
                      }),
                      icon: Icon(
                        star <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: star <= _rating
                            ? SeeraColors.pinkPop
                            : SeeraColors.pinkSoft,
                        size: 32,
                      ),
                    ),
                  if (_rating > 0) Text('$_rating/5'),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('customer-review-comment'),
                controller: _comment,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Bagaimana pengalamanmu berbelanja di Seera?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                key: const ValueKey('customer-review-submit'),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kirim Ulasan'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
