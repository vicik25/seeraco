import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:seeraco/data/admin_session.dart';
import 'package:seeraco/data/seera_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() {
    loggedInAdmin.state = {'id': 1};
  });

  tearDown(() async {
    loggedInAdmin.state = null;
    await SeeraSupabase.clearClientForTesting();
  });

  test('saves the entered stock quantity to Produk.stok', () async {
    Map<String, dynamic>? insertedProduct;
    SeeraSupabase.setClientForTesting(
      SupabaseClient(
        SeeraSupabase.url,
        SeeraSupabase.publishableKey,
        httpClient: MockClient((request) async {
          if (request.method == 'GET' && request.url.path.endsWith('/Produk')) {
            return http.Response('[]', 200, request: request);
          }
          if (request.method == 'POST' &&
              request.url.path.endsWith('/Produk')) {
            insertedProduct = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response('[]', 201, request: request);
          }
          return http.Response('[]', 200, request: request);
        }),
      ),
    );

    await SeeraSupabase.saveProduct(
      id: 'stock-test',
      name: 'Produk uji stok',
      category: 'Aksesori',
      description: '',
      price: 25000,
      costPrice: 10000,
      stock: 8,
      marker: '',
    );

    expect(insertedProduct?['stok'], 8);
  });
}
