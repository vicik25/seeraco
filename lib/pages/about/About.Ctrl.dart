import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../navigator.dart';
import 'About.Data.dart';

class AboutCtrl {
  const AboutCtrl();

  void openBuyers(BuildContext context) {
    aboutBuyerNavigationForm.submit(() async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      nav.to('/buyers');
    });
  }

  void showChannel(BuildContext context, String channel, String handle) {
    aboutSocialActionForm.submit(() async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        SnackBar(
          content: Text('$channel: $handle'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    });
  }
}
