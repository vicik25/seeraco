import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_supabase.dart';
import '../../domains/_models/cart_item.dart';
import '../../domains/_models/product.dart';
import '../../navigator.dart';
import 'OrderTrack.Data.dart';

class OrderTrackCtrl {
  const OrderTrackCtrl();

  void updateCode(String value) => orderTrackCode.state = value;

  void updateWhatsapp(String value) => orderTrackWhatsapp.state = value;

  void submit(BuildContext context) {
    if (orderTrackCode.state.trim().isEmpty ||
        orderTrackWhatsapp.state.trim().isEmpty) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode pesanan dan nomor WhatsApp.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    orderTrackForm.submit(() async {
      orderTrackLookupError.state = null;
      try {
        final order = await SeeraSupabase.findOrder(
          orderCode: orderTrackCode.state.trim(),
          whatsapp: orderTrackWhatsapp.state,
        );
        if (order == null) {
          orderTrackHasMatch.state = false;
          orderTrackHasSearched.state = true;
          return;
        }
        final details = order['Detail_Penjualan'];
        final detailRows = details is List
            ? details.whereType<Map>().toList(growable: false)
            : const <Map>[];
        final productIds = detailRows
            .map((row) => row['kode_produk']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList(growable: false);
        final productRows = await SeeraSupabase.fetchProductsByIds(productIds);
        final products = {
          for (final row in productRows)
            (row['kode_produk']?.toString() ?? ''): Product.fromJson(row),
        };
        orderTrackItems.state = [
          for (final detail in detailRows)
            if (products[detail['kode_produk']?.toString()] case final product?)
              CartItem(
                product: product,
                variant: '',
                quantity: int.tryParse(detail['jumlah'].toString()) ?? 1,
              ),
        ];
        final id = order['id_transaksi']?.toString() ?? '';
        orderTrackCode.state = id;
        orderTrackCustomerName.state = order['nama_customer']?.toString() ?? '';
        orderTrackAddress.state = order['alamat']?.toString() ?? '';
        orderTrackStatus.state =
            order['status']?.toString() ?? 'Menunggu Pembayaran';
        orderTrackTotal.state =
            int.tryParse(order['total_bayar']?.toString() ?? '') ?? 0;
        orderTrackExpectedWhatsapp.state = SeeraSupabase.normalizeWhatsapp(
          order['whatsapp']?.toString() ?? '',
        );
        orderTrackHasMatch.state = true;
        orderTrackCompleted.state =
            orderTrackStatus.state.toLowerCase() == 'selesai';
        savedOrderCode.state = id;
        savedOrderWhatsapp.state = orderTrackExpectedWhatsapp.state;
      } catch (error) {
        orderTrackLookupError.state = error.toString();
        orderTrackHasMatch.state = false;
      }
      orderTrackHasSearched.state = true;
    });
  }

  void openPayment() => nav.to('/payment');
}
