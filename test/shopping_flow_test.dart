import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seeraco/domains/_models/cart_item.dart';
import 'package:seeraco/pages/cart/Cart.Ctrl.dart';
import 'package:seeraco/pages/cart/Cart.Data.dart';
import 'package:seeraco/pages/cart/Cart.View.dart';
import 'package:seeraco/pages/catalog/Catalog.Data.dart';
import 'package:seeraco/pages/catalog/Catalog.View.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.Ctrl.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.Data.dart';
import 'package:seeraco/pages/product_detail/ProductDetail.View.dart';

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

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MaterialApp(home: CartView()));
    await tester.pumpAndSettle();
    expect(find.text('Rp90.000'), findsOneWidget);

    await tester.tap(find.text('Lanjut ke Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Checkout akan segera hadir.'), findsOneWidget);
    expect(tester.takeException(), isNull);

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

      for (final page in [const CatalogView(), const ProductDetailView(), const CartView()]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$page at $width px');
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
  });
}
