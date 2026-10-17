import 'dart:typed_data';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seeraco/data/seera_supabase.dart';
import 'package:seeraco/data/admin_session.dart';
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
import 'package:seeraco/pages/customer_reviews/CustomerReviews.View.dart';
import 'package:seeraco/pages/buyers/Buyers.View.dart';
import 'package:seeraco/pages/home/Home.View.dart';
import 'package:seeraco/pages/review/Review.View.dart';
import 'package:seeraco/pages/review/Review.Data.dart';
import 'package:seeraco/pages/review/Review.Ctrl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabaseRequests = <http.Request>[];
var _returnCustomerReviews = false;

void main() {
  setUp(() {
    _supabaseRequests.clear();
    _returnCustomerReviews = false;
    loggedInAdmin.state = null;
    SeeraSupabase.setClientForTesting(
      SupabaseClient(
        SeeraSupabase.url,
        SeeraSupabase.publishableKey,
        httpClient: MockClient((request) async {
          _supabaseRequests.add(request);
          final path = request.url.path;
          if (path.endsWith('/auth/v1/token')) {
            return http.Response(
              '{"access_token":"test-access-token","token_type":"bearer","expires_in":3600,"expires_at":1792200000,"refresh_token":"test-refresh-token","user":{"id":"00000000-0000-4000-8000-000000000001","aud":"authenticated","role":"authenticated","email":"admin@seeraco.test","app_metadata":{"provider":"email","providers":["email"]},"user_metadata":{},"created_at":"2026-10-17T00:00:00Z"}}',
              200,
              request: request,
            );
          }
          if (path.endsWith('/Produk')) {
            return http.Response(
              '[{"kode_produk":"butterfly-watch","nama_produk":"Butterfly Beads Watch","harga_jual":45000,"kategori":"Jam Beads","deskripsi":"Jam tangan manik warna-warni","hpp_satuan":20000,"status_tampil":true}]',
              200,
              request: request,
            );
          }
          if (path.endsWith('/Users')) {
            final validCredentials =
                request.url.queryParameters['username'] == 'eq.storeadmin' &&
                request.url.queryParameters['password'] == 'eq.secret';
            return http.Response(
              validCredentials
                  ? '{"id":1,"username":"storeadmin","password":"secret"}'
                  : '[]',
              200,
              request: request,
            );
          }
          if (path.endsWith('/Review') && request.method == 'GET') {
            return http.Response(
              _returnCustomerReviews
                  ? '[{"id_review":1,"id_transaksi":null,"nama_customer":"Nadia","rating":5,"komentar":"Suka sekali!","tanggal_review":"2026-10-16T10:00:00Z"}]'
                  : '[]',
              200,
              request: request,
            );
          }
          if (path.endsWith('/Pengaturan')) {
            if (request.method == 'GET') {
              return http.Response(
                '{"id":1,"nama_bank":"Bank Seera","nomor_rekening":"123456789","qris_url":""}',
                200,
                request: request,
              );
            }
            return http.Response('{"id":1}', 200, request: request);
          }
          if (path.endsWith('/Penjualan') &&
              request.method == 'POST' &&
              request.headers['prefer']?.contains('return=representation') ==
                  true) {
            return http.Response('{"id_transaksi":42}', 201, request: request);
          }
          if (path.endsWith('/Penjualan') &&
              request.headers['accept'] ==
                  'application/vnd.pgrst.object+json') {
            return http.Response('{"id_transaksi":42}', 200, request: request);
          }
          if (path.contains('/storage/v1/object/uploads/')) {
            return http.Response(
              '{"Key":"${path.split('/object/').last}"}',
              200,
              request: request,
            );
          }
          return http.Response('[]', 201, request: request);
        }),
      ),
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

  tearDown(SeeraSupabase.clearClientForTesting);

  test('loads storefront products and reviews from Supabase tables', () async {
    await SeeraSupabase.fetchProducts();
    await SeeraSupabase.fetchReviews();

    final productsRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Produk') && request.method == 'GET',
    );
    expect(productsRequest.url.queryParameters['status_tampil'], 'eq.true');

    final reviewsRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Review') && request.method == 'GET',
    );
    expect(
      reviewsRequest.url.queryParameters['select'],
      contains('nama_customer'),
    );
  });

  test('fetches and updates store settings on row id 1', () async {
    loggedInAdmin.state = {'id': 1, 'username': 'storeadmin'};
    final settings = await SeeraSupabase.fetchStoreSettings();
    expect(settings['nama_bank'], 'Bank Seera');
    await SeeraSupabase.updateStoreBankDetails(
      bankName: 'Bank Baru',
      accountNumber: '987654321',
    );

    final fetchRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Pengaturan') && request.method == 'GET',
    );
    expect(fetchRequest.url.queryParameters['id'], 'eq.1');

    final updateRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Pengaturan') && request.method == 'PATCH',
    );
    expect(updateRequest.url.queryParameters['id'], 'eq.1');
    expect(jsonDecode(updateRequest.body), {
      'nama_bank': 'Bank Baru',
      'nomor_rekening': '987654321',
    });
  });

  test('uploads QRIS to storage and saves its URL to settings row 1', () async {
    loggedInAdmin.state = {'id': 1, 'username': 'storeadmin'};
    final file = XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: 'qris.png',
      path: 'qris.png',
    );
    final url = await SeeraSupabase.uploadStoreQris(file);

    expect(url, contains('/storage/v1/object/public/uploads/settings/qris_'));
    final storageRequest = _supabaseRequests.singleWhere(
      (request) => request.url.path.contains('/storage/v1/object/uploads/'),
    );
    expect(storageRequest.method, 'POST');
    final settingsRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Pengaturan') && request.method == 'PATCH',
    );
    expect(settingsRequest.url.queryParameters['id'], 'eq.1');
    expect(jsonDecode(settingsRequest.body), {'qris_url': url});
  });

  testWidgets('customer can browse reviews and submit a new review', (
    tester,
  ) async {
    _returnCustomerReviews = true;
    await tester.pumpWidget(const MaterialApp(home: CustomerReviewsView()));
    await tester.pumpAndSettle();

    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('Suka sekali!'), findsOneWidget);
    await tester.tap(find.text('Tulis Ulasan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customer-review-name')),
      'Rani',
    );
    await tester.tap(find.byKey(const ValueKey('customer-review-rating-5')));
    await tester.enterText(
      find.byKey(const ValueKey('customer-review-comment')),
      'Produk bagus dan pengirimannya cepat.',
    );
    await tester.tap(find.byKey(const ValueKey('customer-review-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Ulasan berhasil dikirim. Terima kasih!'), findsOneWidget);
    final insertRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Review') && request.method == 'POST',
    );
    expect(jsonDecode(insertRequest.body), {
      'nama_customer': 'Rani',
      'rating': 5,
      'komentar': 'Produk bagus dan pengirimannya cepat.',
    });
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('home and admin product list render API-loaded products', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeView()));
    await tester.pumpAndSettle();
    expect(catalogLoadError.state, isNull, reason: catalogLoadError.state);
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

    expect(find.text('Masuk ke Panel Admin'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byKey(const ValueKey('admin-username')),
      'storeadmin',
    );
    await tester.enterText(
      find.byKey(const ValueKey('admin-password')),
      'secret',
    );
    await tester.tap(find.text('Masuk'));
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
    final settingsFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(settingsFields, hasLength(2));
    expect(settingsFields.every((field) => field.enabled), isTrue);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);

    final loginRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Users') && request.method == 'GET',
    );
    expect(loginRequest.url.queryParameters['username'], 'eq.storeadmin');
    expect(loginRequest.url.queryParameters['password'], 'eq.secret');
    expect(loggedInAdmin.state, {'id': 1, 'username': 'storeadmin'});

    await tester.tap(find.byTooltip('Keluar dari akun admin'));
    await tester.pumpAndSettle();
    expect(loggedInAdmin.state, isNull);
    expect(find.text('Masuk ke Panel Admin'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('admin-username')),
      'wrong-user',
    );
    await tester.enterText(
      find.byKey(const ValueKey('admin-password')),
      'wrong-password',
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Username atau kata sandi salah.'), findsOneWidget);
    expect(loggedInAdmin.state, isNull);
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
    final saleRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Penjualan') && request.method == 'POST',
    );
    final sale = jsonDecode(saleRequest.body) as Map<String, dynamic>;
    expect(sale['nama_customer'], 'Rani Seera');
    expect(sale['whatsapp'], '6281234567890');
    expect(sale['total_bayar'], checkoutTotal);
    final detailRequest = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Detail_Penjualan') &&
          request.method == 'POST',
    );
    final details = jsonDecode(detailRequest.body) as List<dynamic>;
    expect(details.single, {'id': 42, 'kode_produk': product.id, 'jumlah': 2});

    paymentProofFile.state = XFile.fromData(
      Uint8List.fromList(const [1, 2, 3]),
      name: 'bukti-transfer.jpg',
      path: 'bukti-transfer.jpg',
    );
    paymentProofSelected.state = true;
    PaymentCtrl().submit(tester.element(find.byType(PaymentView)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan pesanan'), findsOneWidget);
    expect(find.text('42'), findsWidgets);
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
    final paymentUpdate = _supabaseRequests.singleWhere(
      (request) =>
          request.url.path.endsWith('/Penjualan') && request.method == 'PATCH',
    );
    final paymentUpdateBody =
        jsonDecode(paymentUpdate.body) as Map<String, dynamic>;
    expect(paymentUpdateBody['status'], 'Proses');
    expect(
      paymentUpdateBody['bukti_bayar'],
      contains('/storage/v1/object/public/uploads/'),
    );

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
