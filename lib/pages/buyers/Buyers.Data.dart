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
  () => const [
    BuyerProfile(
      displayName: 'Ru***a',
      productName: 'Butterfly Beads Watch',
      city: 'Bandung',
      date: '12 Okt 2026',
      avatarColor: Color(0xFFB88CFF),
    ),
    BuyerProfile(
      displayName: 'Sa***i',
      productName: 'Pastel Daisy Bracelet',
      city: 'Yogyakarta',
      date: '11 Okt 2026',
      avatarColor: Color(0xFFA9DCF5),
    ),
    BuyerProfile(
      displayName: 'De***a',
      productName: 'Sweetheart Beads Strap',
      city: 'Jakarta',
      date: '10 Okt 2026',
      avatarColor: Color(0xFFFF8BBF),
    ),
    BuyerProfile(
      displayName: 'An***n',
      productName: 'Butterfly Beads Watch',
      city: 'Surabaya',
      date: '9 Okt 2026',
      avatarColor: Color(0xFFE6FF70),
    ),
    BuyerProfile(
      displayName: 'Pembeli anonim',
      productName: 'Bestie Beads Set',
      city: 'Malang',
      date: '8 Okt 2026',
      avatarColor: Color(0xFFE9E2E6),
      isAnonymous: true,
    ),
    BuyerProfile(
      displayName: 'Mi***a',
      productName: 'Pastel Daisy Bracelet',
      city: 'Semarang',
      date: '7 Okt 2026',
      avatarColor: Color(0xFFFFD3E6),
    ),
    BuyerProfile(
      displayName: 'Al***a',
      productName: 'Tiny Flower Bracelet',
      city: 'Depok',
      date: '6 Okt 2026',
      avatarColor: Color(0xFFF7F6E6),
    ),
    BuyerProfile(
      displayName: 'Pembeli anonim',
      productName: 'Sweetheart Beads Strap',
      city: 'Bogor',
      date: '5 Okt 2026',
      avatarColor: Color(0xFFE9E2E6),
      isAnonymous: true,
    ),
  ],
  autoDisposeWhenNotUsed: false,
);

final visibleBuyerCount = RM.inject<int>(
  () => 4,
  autoDisposeWhenNotUsed: false,
);
final loadMoreBuyersForm = RM.injectForm();
final openAboutFromBuyersForm = RM.injectForm();

const seeraTotalBuyers = 1287;
