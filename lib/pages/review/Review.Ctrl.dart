import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../navigator.dart';
import '../order_track/OrderTrack.Data.dart';
import 'Review.Data.dart';

class ReviewCtrl {
  const ReviewCtrl();

  void selectRating(int productIndex, int rating) {
    if (rating < 1 || rating > 5) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }
    final ratings = [...reviewRatings.state];
    if (productIndex < 0 || productIndex >= ratings.length) {
      throw RangeError.index(productIndex, ratings, 'productIndex');
    }
    ratings[productIndex] = rating;
    reviewRatings.state = ratings;
  }

  void updateReview(String value) {
    reviewText.state = value;
  }

  void submit(BuildContext context) {
    if (reviewRatings.state.any((rating) => rating == 0)) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Pilih rating untuk setiap produk terlebih dahulu.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }
    if (reviewText.state.trim().isEmpty) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Tulis sedikit cerita tentang pesananmu.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    reviewForm.submit(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      orderTrackCode.state = reviewOrderCode;
      orderTrackWhatsapp.state = trackedOrderWhatsapp;
      orderTrackExpectedWhatsapp.state = trackedOrderWhatsapp;
      orderTrackCompleted.state = true;
      orderTrackHasMatch.state = true;
      orderTrackHasSearched.state = true;
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Ulasanmu sudah berhasil dikirim.'),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      nav.to('/order-track');
    });
  }

  void returnToOrderTrack() => nav.to('/order-track');
}
