import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../navigator.dart';
import '../../data/seera_api.dart';
import '../order_track/OrderTrack.Data.dart';
import '../catalog/Catalog.Data.dart';
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
    if (!orderTrackCompleted.state) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text(
            'Ulasan hanya bisa dikirim untuk pesanan yang sudah selesai.',
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }
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
    if (reviewText.state.trim().length < 10) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Ulasan minimal 10 karakter ya.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    reviewForm.submit(() async {
      try {
        for (var index = 0; index < reviewProducts.state.length; index++) {
          await SeeraApi.postForm('simpan_review.php', {
            'kode_pesanan': orderTrackCode.state,
            'nama_produk': reviewProducts.state[index],
            'rating': reviewRatings.state[index].toString(),
            'ulasan': reviewText.state.trim(),
          });
        }
        await loadStoreData(refresh: true);
        if (!context.mounted) return;
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
      } catch (error) {
        if (!context.mounted) return;
        RM.scaffold.context = context;
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text('Ulasan gagal dikirim: $error'),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    });
  }

  void returnToOrderTrack() => nav.to('/order-track');
}
