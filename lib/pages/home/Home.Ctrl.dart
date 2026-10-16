import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domains/_models/product.dart';
import '../../navigator.dart';
import '../product_detail/ProductDetail.Ctrl.dart';

class HomeCtrl {
  const HomeCtrl();

  static const instagramUrl =
      'https://www.instagram.com/seera.co_?exln=MTN4czhrcWw0ZjcyMw==';
  static const shopeeUrl = 'https://s.shopee.co.id/AKbORZhXhd';
  static const whatsappUrl = 'https://wa.me/6285795531936';

  void openCatalog() => nav.to('/catalog');

  void openHome() => nav.to('/home');

  void openCart() => nav.to('/cart');

  void openBuyers() => nav.to('/buyers');

  void openAbout() => nav.to('/about');

  void openOrderTrack() => nav.to('/order-track');

  void openAdmin() => nav.to('/admin');

  void openProduct(Product product) {
    const ProductDetailCtrl().selectProduct(product);
    nav.to('/product-detail');
  }

  Future<void> openExternal(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan tidak dapat dibuka.')),
      );
    }
  }
}
