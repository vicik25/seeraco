import 'package:flutter/material.dart';

import '../../core/theme/seera_colors.dart';
import '../../data/seera_supabase.dart';
import '../../domains/_models/recent_buyer.dart';
import '../home/Home.Data.dart';
import '../../navigator.dart';
import 'Buyers.Data.dart';

class BuyersCtrl {
  const BuyersCtrl();

  Future<void> refresh() => _load();

  Future<void> _load() async {
    isLoadingSeeraBuyers.state = true;
    seeraBuyersError.state = null;
    try {
      final rows = await SeeraSupabase.fetchCompletedBuyerStories();
      final buyers = [
        for (var index = 0; index < rows.length; index++)
          BuyerProfile(
            displayName:
                rows[index]['display_name']?.toString() ?? 'Pembeli Seera',
            productName:
                rows[index]['product_summary']?.toString() ?? 'Produk Seera',
            city: 'Pesanan selesai',
            date: _formatDate(rows[index]['purchase_date']),
            avatarColor: index.isEven
                ? SeeraColors.skyPastel
                : SeeraColors.pinkSoft,
            isAnonymous:
                rows[index]['display_name']?.toString().startsWith(
                  'Pembeli Seera',
                ) ??
                true,
          ),
      ];
      seeraBuyers.state = buyers;
      recentBuyers.state = buyers
          .take(4)
          .map(
            (buyer) => RecentBuyer(
              displayName: buyer.displayName,
              productName: buyer.productName,
              city: buyer.city,
              date: buyer.date,
            ),
          )
          .toList(growable: false);
      final requestedCount = visibleBuyerCount.state < 1
          ? 4
          : visibleBuyerCount.state;
      visibleBuyerCount.state = buyers.isEmpty
          ? 0
          : requestedCount.clamp(1, buyers.length);
    } catch (error) {
      seeraBuyersError.state = error.toString();
    } finally {
      isLoadingSeeraBuyers.state = false;
    }
  }

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

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Tanggal tidak tersedia';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
