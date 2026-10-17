import '../../data/seera_supabase.dart';
import '../../domains/_models/product_review.dart';
import 'CustomerReviews.Data.dart';

class CustomerReviewsCtrl {
  const CustomerReviewsCtrl();

  Future<void> loadReviews() async {
    isCustomerReviewsLoading.state = true;
    customerReviewsError.state = null;
    try {
      final rows = await SeeraSupabase.fetchReviews();
      customerReviews.state = rows
          .map(ProductReview.fromJson)
          .where((review) => review.comment.trim().isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      customerReviewsError.state = error.toString();
    } finally {
      isCustomerReviewsLoading.state = false;
    }
  }

  Future<void> submitReview({
    required String customerName,
    required int rating,
    required String comment,
  }) async {
    final name = customerName.trim();
    final trimmedComment = comment.trim();
    if (name.isEmpty) {
      throw const FormatException('Nama Anda wajib diisi.');
    }
    if (rating < 1 || rating > 5) {
      throw const FormatException('Pilih rating dari 1 sampai 5 bintang.');
    }
    if (trimmedComment.isEmpty) {
      throw const FormatException('Komentar ulasan wajib diisi.');
    }
    await SeeraSupabase.createReview(
      customerName: name,
      rating: rating,
      comment: trimmedComment,
    );
    await loadReviews();
  }
}
