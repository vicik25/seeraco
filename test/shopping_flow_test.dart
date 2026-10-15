import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seeraco/domains/_models/cart_item.dart';
import 'package:seeraco/pages/cart/Cart.Ctrl.dart';
import 'package:seeraco/pages/cart/Cart.Data.dart';
import 'package:seeraco/pages/cart/Cart.View.dart';
import 'package:seeraco/pages/catalog/Catalog.Data.dart';
import 'package:seeraco/pages/catalog/Catalog.View.dart';
import 'package:seeraco/pages/checkout/Checkout.Data.dart';
import 'package:seeraco/pages/checkout/Checkout.Ctrl.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.Ctrl.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.Data.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.View.dart';
import 'package:seeraco/navigator.dart';
import 'package:seeraco/pages/checkout/Checkout.View.dart';
import 'package:seeraco/pages/order_track/OrderTrack.View.dart';
import 'package:seeraco/pages/order_track/OrderTrack.Data.dart';
import 'package:seeraco/pages/payment/Payment.View.dart';
import 'package:seeraco/pages/payment/Payment.Data.dart';
import 'package:seeraco/pages/payment/Payment.Ctrl.dart';
import 'package:seeraco/pages/about/About.View.dart';
import 'package:seeraco/pages/buyers/Buyers.View.dart';
import 'package:seeraco/pages/review/Review.View.dart';
import 'package:seeraco/pages/review/Review.Data.dart';
import 'package:seeraco/pages/review/Review.Ctrl.dart';

void main() {
  testWidgets('adds a product to the cart and updates its subtotal', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final product = catalogProducts.state.first;
    cartItems.state = const [];
    selectedProduct.state = product;
    selectedProductQuantity.state = 1;
    const ProductDetailCtrl().increaseQuantity();

    await tester.pumpWidget(const MaterialApp(home: ProductDetailView()));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Tambah ke Keranjang'));
    await tester.pumpAndSettle();

    expect(find.text('${product.name} ditambahkan ke keranjang.'), findsOneWidget);
    expect(cartItems.state, hasLength(1));
    expect(cartItems.state.single.quantity, 2);
    expect(cartSubtotal, product.price * 2);
    expect(checkoutSubtotal, cartSubtotal);
    expect(checkoutTotal, cartSubtotal + checkoutShipping + checkoutUniqueCode);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp.router(routerConfig: nav.routerConfig));
    await tester.pump(const Duration(milliseconds: 701));
    await tester.pumpAndSettle();
    nav.to('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Rp90.000'), findsOneWidget);

    await tester.tap(find.text('Lanjut ke Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Data penerima'), findsOneWidget);
    expect(find.text('Rp90.000'), findsOneWidget);
    expect(find.text('Rp94.127'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'Rani Seera');
    await tester.enterText(find.byType(TextFormField).at(1), '81234567890');
    await tester.enterText(find.byType(TextFormField).at(2), 'rani@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'Jalan Melati 10, Bandung');
    const CheckoutCtrl().togglePrivacy(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Pesananmu sudah dibuat!'), findsOneWidget);
    expect(find.text('Kirim Bukti Bayar'), findsOneWidget);
    expect(paymentTotal, checkoutTotal);

    PaymentCtrl().selectProof();
    PaymentCtrl().submit(tester.element(find.byType(PaymentView)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan pesanan'), findsOneWidget);
    expect(find.text('SEERA-261013-001'), findsWidgets);
    expect(find.text('Rp94.127'), findsOneWidget);
    expect(find.text('Jalan Melati 10, Bandung'), findsOneWidget);

    orderTrackCompleted.state = true;
    await tester.pumpAndSettle();
    expect(find.text('Tulis Ulasan'), findsOneWidget);
    nav.to('/review');
    await tester.pumpAndSettle();
    expect(find.text('Pesanan selesai'), findsOneWidget);
    orderTrackCompleted.state = false;

    nav.to('/cart');
    await tester.pumpAndSettle();
    const CartCtrl().changeQuantity(cartItems.state.single, 1);
    await tester.pumpAndSettle();
    expect(cartItems.state.single.quantity, 3);
    expect(cartSubtotal, product.price * 3);

    const CartCtrl().removeItem(cartItems.state.single);
    await tester.pumpAndSettle();
    expect(cartItems.state, isEmpty);
    expect(find.text('Keranjangmu masih kosong'), findsOneWidget);
    expect(find.text('Lihat Produk'), findsOneWidget);
  });

  testWidgets('catalog, detail, and cart fit mobile and desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    selectedProduct.state = catalogProducts.state.first;
    cartItems.state = [CartItem(product: catalogProducts.state.first, variant: 'Pink', quantity: 1)];

    for (final width in [320.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 900);
      cartItems.state = [CartItem(product: catalogProducts.state.first, variant: 'Pink', quantity: 1)];

      for (final page in [
        const CatalogView(),
        const ProductDetailView(),
        const CartView(),
        const CheckoutView(),
        const PaymentView(),
        const OrderTrackView(),
        const BuyersView(),
        const AboutView(),
        const ReviewView(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$page at $width px');
      }

      cartItems.state = const [];
      await tester.pumpWidget(const MaterialApp(home: CartView()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'CartView empty at $width px');
    }
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('review ratings can be selected and written interactively', (tester) async {
    expect(reviewProducts.state, ['Pastel Daisy Bracelet']);
    reviewRatings.state = [0];
    reviewText.state = '';

    await tester.pumpWidget(const MaterialApp(home: ReviewView()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Tulis Ulasan'), findsOneWidget);
    expect(find.text('Pesanan selesai'), findsOneWidget);
    expect(find.text('Pastel Daisy Bracelet'), findsOneWidget);
    const ReviewCtrl().selectRating(0, 5);
    await tester.pumpAndSettle();
    expect(find.text('5/5'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Gelangnya cantik dan nyaman dipakai.');
    await tester.pumpAndSettle();
    expect(reviewText.state, 'Gelangnya cantik dan nyaman dipakai.');
    expect(tester.takeException(), isNull);
  });
}
