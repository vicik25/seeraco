import 'package:flutter/material.dart';

import '../../navigator.dart';
import 'Buyers.Data.dart';

class BuyersCtrl {
  const BuyersCtrl();

  void loadMore() {
    loadMoreBuyersForm.submit(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      visibleBuyerCount.state = (visibleBuyerCount.state + 4)
          .clamp(0, seeraBuyers.state.length)
          .toInt();
    });
  }

  void openAbout(BuildContext context) {
    openAboutFromBuyersForm.submit(() async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      nav.to('/about');
    });
  }
}
