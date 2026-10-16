import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seeraco/data/seera_api.dart';
import 'package:seeraco/domains/_models/cart_item.dart';
import 'package:seeraco/domains/_models/product.dart';
import 'package:seeraco/domains/_models/product_review.dart';
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
import 'package:seeraco/pages/admin/Admin.View.dart';
import 'package:seeraco/pages/buyers/Buyers.View.dart';
import 'package:seeraco/pages/home/Home.View.dart';
import 'package:seeraco/pages/review/Review.View.dart';
import 'package:seeraco/pages/review/Review.Data.dart';
import 'package:seeraco/pages/review/Review.Ctrl.dart';

void main() {
  setUp(() {
    SeeraApi.setClientForTesting(
      MockClient((request) async {
        switch (request.url.path.split('/').last) {
          case 'get_produk.php':
            return http.Response(
              '[{"id_produk":"butterfly-watch","nama_produk":"Butterfly Beads Watch","harga":45000,"kategori":"Jam Beads","deskripsi":"Jam tangan manik warna-warni","hpp":20000}]',
              200,
              headers: {'content-type': 'application/json'},
            );
          case 'get_review.php':
            return http.Response('[]', 200);
          case 'simpan_transaksi.php':
            return http.Response(
              '{"success":true,"kode_pesanan":"SEERA-TEST-001"}',
              200,
            );
          default:
            return http.Response('{"success":true,"status":"Proses"}', 200);
        }
      }),
    );
    catalogProducts.state = const [
      Product(
        id: 'butterfly-watch',
        name: 'Butterfly Beads Watch',
        price: 45000,
        category: 'Jam Beads',
        description: 'Jam tangan manik warna-warni',
      ),
    ];
  });

  tearDown(SeeraApi.clearClientForTesting);

  test('parses the live API product and review field names', () {
    final product = Product.fromJson({
      'kode_produk': 'PRD-001',
      'nama_produk': 'Beads Watch Garden Hijau',
      'kategori': null,
      'stok': '100',
      'hpp_satuan': '13100.00',
      'harga_jual': '21500.00',
    });
    expect(product.id, 'PRD-001');
    expect(product.name, 'Beads Watch Garden Hijau');
    expect(product.price, 21500);
    expect(product.costPrice, 13100);
    expect(product.stock, 100);
    expect(
      Product.fromJson({
        'nama_produk': 'Harga berformat',
        'harga_jual': '21.500',
      }).price,
      21500,
    );

    final review = ProductReview.fromJson({
      'id_review': '3',
      'nama_customer': 'Azza',
      'rating': '4',
      'komentar': 'Lucu banget buat kado temen.',
    });
    expect(review.id, '3');
    expect(review.customerName, 'Azza');
    expect(review.comment, 'Lucu banget buat kado temen.');
    expect(review.rating, 4);
  });

  test(
    'identifies HTML protection responses returned by the API host',
    () async {
      SeeraApi.setClientForTesting(
        MockClient(
          (_) async => http.Response(
            '<html><script>challenge()</script></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        ),
      );

      await expectLater(
        SeeraApi.getList('get_produk.php'),
        throwsA(
          isA<SeeraApiException>().having(
            (error) => error.message,
            'message',
            contains('halaman HTML/proteksi'),
          ),
        ),
      );
    },
  );

  testWidgets('home and admin product list render API-loaded products', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeView()));
    await tester.pumpAndSettle();
    expect(find.text('Butterfly Beads Watch'), findsWidgets);
    expect(find.text('Pastel Daisy Bracelet'), findsNothing);
    expect(find.text('Panel Admin'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Panel Admin')).dy,
      greaterThan(
        tester
            .getTopLeft(
              find.text(
                'Semua produk dibuat pre-order. Estimasi tiba 3 sampai 5 hari',
              ),
            )
            .dy,
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: AdminView()));
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan toko'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    expect(find.text('Butterfly Beads Watch'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Manajemen pesanan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Ulasan'));
    await tester.pumpAndSettle();
    expect(find.text('Ulasan pelanggan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan toko'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds a product to the cart and updates its subtotal', (
    tester,
  ) async {
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

    expect(
      find.text('${product.name} ditambahkan ke keranjang.'),
      findsOneWidget,
    );
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
    expect(find.text('Data Penerima'), findsOneWidget);
    expect(find.text('Rp90.000'), findsOneWidget);
    expect(find.text('Rp94.127'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'Rani Seera');
    await tester.enterText(find.byType(TextFormField).at(1), '81234567890');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'rani@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Jalan Melati 10, Bandung',
    );
    expect(checkoutName.state, 'Rani Seera');
    expect(checkoutWhatsapp.state, '81234567890');
    expect(checkoutEmail.state, 'rani@example.com');
    expect(checkoutAddress.state, 'Jalan Melati 10, Bandung');
    const CheckoutCtrl().togglePrivacy(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Pesananmu sudah dibuat!'), findsOneWidget);
    expect(find.text('Kirim Bukti Bayar'), findsOneWidget);
    expect(paymentTotal, checkoutTotal);

    paymentProofFile.state = XFile.fromData(
      Uint8List.fromList(const [1, 2, 3]),
      name: 'bukti-transfer.jpg',
    );
    paymentProofSelected.state = true;
    PaymentCtrl().submit(tester.element(find.byType(PaymentView)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan pesanan'), findsOneWidget);
    expect(find.text('SEERA-TEST-001'), findsWidgets);
    expect(find.text('Proses · Bukti bayar diterima'), findsOneWidget);
    expect(find.text('Rp94.127'), findsOneWidget);
    expect(find.text('Jalan Melati 10, Bandung'), findsOneWidget);
    expect(reviewProducts.state, [product.name]);
    expect(orderTrackItems.state.single.quantity, 2);
    expect(
      orderTrackTotal.state,
      product.price * 2 + checkoutShipping + checkoutUniqueCode,
    );
    expect(orderTrackAddress.state, 'Jalan Melati 10, Bandung');

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

  testWidgets('product detail keeps its content visible above the action bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1109, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final product = catalogProducts.state.first;
    selectedProduct.state = product;

    await tester.pumpWidget(const MaterialApp(home: ProductDetailView()));
    await tester.pumpAndSettle();

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('JUMLAH'), findsOneWidget);
    expect(tester.getSize(find.byType(ListView).first).height, greaterThan(0));
    expect(tester.getSize(find.byType(ListView).first).width, greaterThan(760));
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog, detail, and cart fit mobile and desktop widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    selectedProduct.state = catalogProducts.state.first;
    cartItems.state = [
      CartItem(
        product: catalogProducts.state.first,
        variant: 'Pink',
        quantity: 1,
      ),
    ];

    for (final width in [320.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 900);
      cartItems.state = [
        CartItem(
          product: catalogProducts.state.first,
          variant: 'Pink',
          quantity: 1,
        ),
      ];

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
      expect(
        tester.takeException(),
        isNull,
        reason: 'CartView empty at $width px',
      );
    }
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('review ratings can be selected and written interactively', (
    tester,
  ) async {
    reviewProducts.state = ['Pastel Daisy Bracelet'];
    reviewRatings.state = [0];
    reviewText.state = '';
    orderTrackCompleted.state = true;
    addTearDown(() => orderTrackCompleted.state = false);

    await tester.pumpWidget(const MaterialApp(home: ReviewView()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Tulis Ulasan'), findsOneWidget);
    expect(find.text('Pesanan selesai'), findsOneWidget);
    expect(find.text('Pastel Daisy Bracelet'), findsOneWidget);
    const ReviewCtrl().selectRating(0, 5);
    await tester.pumpAndSettle();
    expect(find.text('5/5'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'Gelangnya cantik dan nyaman dipakai.',
    );
    await tester.pumpAndSettle();
    expect(reviewText.state, 'Gelangnya cantik dan nyaman dipakai.');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'checkout displays field validation errors and clears them as corrected',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      cartItems.state = [
        CartItem(
          product: catalogProducts.state.first,
          variant: 'Pink',
          quantity: 1,
        ),
      ];
      checkoutName.state = '';
      checkoutWhatsapp.state = '';
      checkoutEmail.state = '';
      checkoutAddress.state = '';
      checkoutPrivacyAccepted.state = false;

      await tester.pumpWidget(const MaterialApp(home: CheckoutView()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buat Pesanan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama penerima wajib diisi.'), findsOneWidget);
      expect(find.text('Masukkan nomor WhatsApp yang valid.'), findsOneWidget);
      expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
      expect(find.text('Masukkan alamat lengkap.'), findsOneWidget);
      expect(
        find.text('Persetujuan Kebijakan Privasi wajib dicentang.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('checkout-name')),
        'Rani Seera',
      );
      await tester.pumpAndSettle();
      expect(find.text('Nama penerima wajib diisi.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('review form is unavailable until an order is complete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    orderTrackCompleted.state = false;
    reviewProducts.state = ['Pastel Daisy Bracelet'];
    reviewRatings.state = [0];

    await tester.pumpWidget(const MaterialApp(home: ReviewView()));
    await tester.pumpAndSettle();

    expect(
      find.text('Ulasan hanya bisa ditulis setelah pesanan selesai.'),
      findsOneWidget,
    );
    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Kirim Ulasan'),
    );
    expect(submitButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
