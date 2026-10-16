import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class BuyerProfile {
  const BuyerProfile({
    required this.displayName,
    required this.productName,
    required this.city,
    required this.date,
    required this.avatarColor,
    this.isAnonymous = false,
  });

  final String displayName;
  final String productName;
  final String city;
  final String date;
  final Color avatarColor;
  final bool isAnonymous;
}

final seeraBuyers = RM.inject<List<BuyerProfile>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);

final visibleBuyerCount = RM.inject<int>(
  () => 4,
  autoDisposeWhenNotUsed: false,
);
final loadMoreBuyersForm = RM.injectForm();
final openAboutFromBuyersForm = RM.injectForm();
