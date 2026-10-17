import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_session.dart';
import '../domains/_models/cart_item.dart';

class SeeraSupabase {
  SeeraSupabase._();

  static const url = 'https://ilovqtophpideljzbkda.supabase.co';
  static const publishableKey =
      'sb_publishable_Z6zE8Kh1MvefGIXUgjrHOQ_nHy-garP';
  static const storageBucket = 'uploads';

  static SupabaseClient? _testClient;

  static SupabaseClient get client => _testClient ?? Supabase.instance.client;

  static Future<void> initialize() =>
      Supabase.initialize(url: url, publishableKey: publishableKey);

  @visibleForTesting
  static void setClientForTesting(SupabaseClient client) {
    _testClient = client;
  }

  @visibleForTesting
  static Future<void> clearClientForTesting() async {
    final client = _testClient;
    _testClient = null;
    await client?.dispose();
  }

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    final rows = await client
        .from('Produk')
        .select()
        .eq('status_tampil', true)
        .order('nama_produk');
    return _maps(rows);
  }

  static Future<List<Map<String, dynamic>>> fetchProductsByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const [];
    final rows = await client
        .from('Produk')
        .select()
        .inFilter('kode_produk', ids);
    return _maps(rows);
  }

  static Future<List<Map<String, dynamic>>> fetchReviews() async {
    final rows = await client
        .from('Review')
        .select(
          'id_review,id_transaksi,nama_customer,rating,komentar,tanggal_review',
        )
        .order('tanggal_review', ascending: false);
    return _maps(rows);
  }

  static Future<Map<String, dynamic>> fetchStoreSettings() async {
    final row = await client
        .from('Pengaturan')
        .select('id,nama_bank,nomor_rekening,qris_url')
        .eq('id', 1)
        .maybeSingle();
    if (row == null) {
      throw StateError('Pengaturan toko dengan id 1 tidak ditemukan.');
    }
    return Map<String, dynamic>.from(row);
  }

  static Future<void> updateStoreBankDetails({
    required String bankName,
    required String accountNumber,
  }) async {
    _requireAdminSession();
    final row = await client
        .from('Pengaturan')
        .update({
          'nama_bank': bankName.trim(),
          'nomor_rekening': accountNumber.trim(),
        })
        .eq('id', 1)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw StateError('Pengaturan toko tidak ditemukan atau akses ditolak.');
    }
  }

  static Future<String> uploadStoreQris(XFile file) async {
    _requireAdminSession();
    final path =
        'settings/qris_${DateTime.now().microsecondsSinceEpoch}.${_extension(file.name)}';
    await client.storage
        .from(storageBucket)
        .uploadBinary(
          path,
          await file.readAsBytes(),
          fileOptions: FileOptions(
            contentType: _imageContentType(file.name),
            upsert: false,
          ),
        );
    final url = client.storage.from(storageBucket).getPublicUrl(path);
    final updated = await client
        .from('Pengaturan')
        .update({'qris_url': url})
        .eq('id', 1)
        .select('id')
        .maybeSingle();
    if (updated == null) {
      throw StateError(
        'QRIS berhasil diunggah, tetapi URL tidak tersimpan di pengaturan toko.',
      );
    }
    return url;
  }

  static Future<dynamic> createOrder({
    required String customerName,
    required String whatsapp,
    required String email,
    required String address,
    required int shipping,
    required int uniqueCode,
    required int total,
    required List<CartItem> items,
  }) async {
    final response = await client
        .from('Penjualan')
        .insert({
          'nama_customer': customerName,
          'whatsapp': normalizeWhatsapp(whatsapp),
          'email': email,
          'alamat': address,
          'ongkir': shipping,
          'kode_unik': uniqueCode,
          'total_bayar': total,
          'status': 'Menunggu Pembayaran',
        })
        .select('id_transaksi')
        .single();
    final orderId = response['id_transaksi'];

    try {
      await client
          .from('Detail_Penjualan')
          .insert(
            items
                .map(
                  (item) => {
                    'id': orderId,
                    'kode_produk': item.product.id,
                    'jumlah': item.quantity,
                  },
                )
                .toList(growable: false),
          );
    } catch (error) {
      try {
        await client.from('Penjualan').delete().eq('id_transaksi', orderId);
      } catch (_) {
        throw StateError(
          'Pesanan $orderId tersimpan tetapi detail item gagal disimpan. '
          'Hubungi admin untuk pemeriksaan sebelum mencoba checkout lagi. '
          'Detail: $error',
        );
      }
      rethrow;
    }
    return orderId;
  }

  static Future<String> uploadPaymentProof({
    required dynamic orderId,
    required XFile file,
  }) async {
    final path =
        'payment/${orderId}_${DateTime.now().microsecondsSinceEpoch}'
        '.${_extension(file.name)}';
    await client.storage
        .from(storageBucket)
        .uploadBinary(
          path,
          await file.readAsBytes(),
          fileOptions: FileOptions(
            contentType: _imageContentType(file.name),
            upsert: false,
          ),
        );
    final url = client.storage.from(storageBucket).getPublicUrl(path);
    final updated = await client
        .from('Penjualan')
        .update({'bukti_bayar': url, 'status': 'Proses'})
        .eq('id_transaksi', orderId)
        .select('id_transaksi')
        .maybeSingle();
    if (updated == null) {
      throw StateError(
        'Foto berhasil diunggah, tetapi pesanan tidak ditemukan atau akses update ditolak.',
      );
    }
    return url;
  }

  static Future<void> createReview({
    dynamic orderId,
    required String customerName,
    required int rating,
    required String comment,
  }) async {
    await client.from('Review').insert({
      'id_transaksi': ?orderId,
      'nama_customer': customerName,
      'rating': rating,
      'komentar': comment,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchProductsForAdmin() async {
    _requireAdminSession();
    final rows = await client.from('Produk').select().order('nama_produk');
    return _maps(rows);
  }

  static Future<String?> uploadProductImage(XFile file) async {
    final path =
        'products/${DateTime.now().microsecondsSinceEpoch}.${_extension(file.name)}';
    await client.storage
        .from(storageBucket)
        .uploadBinary(
          path,
          await file.readAsBytes(),
          fileOptions: FileOptions(
            contentType: _imageContentType(file.name),
            upsert: false,
          ),
        );
    return client.storage.from(storageBucket).getPublicUrl(path);
  }

  static Future<void> saveProduct({
    required String id,
    required String name,
    required String category,
    required String description,
    required int price,
    required int costPrice,
    required String marker,
    XFile? image,
  }) async {
    _requireAdminSession();
    final imageUrl = image == null ? null : await uploadProductImage(image);
    final values = <String, dynamic>{
      'kode_produk': id,
      'nama_produk': name,
      'kategori': category,
      'deskripsi': description,
      'harga_jual': price,
      'hpp_satuan': costPrice,
      'penanda': marker,
      'status_tampil': true,
      'gambar': ?imageUrl,
    };
    if (await productExists(id)) {
      values.remove('kode_produk');
      final updated = await client
          .from('Produk')
          .update(values)
          .eq('kode_produk', id)
          .select('kode_produk')
          .maybeSingle();
      if (updated == null) {
        throw StateError('Produk tidak ditemukan atau akses update ditolak.');
      }
    } else {
      await client.from('Produk').insert(values);
    }
  }

  static Future<bool> productExists(String id) async {
    final row = await client
        .from('Produk')
        .select('kode_produk')
        .eq('kode_produk', id)
        .maybeSingle();
    return row != null;
  }

  static Future<void> deleteProduct(String id) async {
    _requireAdminSession();
    final deleted = await client
        .from('Produk')
        .delete()
        .eq('kode_produk', id)
        .select('kode_produk')
        .maybeSingle();
    if (deleted == null) {
      throw StateError('Produk tidak ditemukan atau akses hapus ditolak.');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    _requireAdminSession();
    final rows = await client
        .from('Penjualan')
        .select(
          'id_transaksi,tanggal_transaksi,nama_customer,whatsapp,alamat,ongkir,kode_unik,total_bayar,status,bukti_bayar,Detail_Penjualan(kode_produk,jumlah)',
        )
        .order('tanggal_transaksi', ascending: false);
    return _maps(rows);
  }

  static Future<void> updateOrderStatus({
    required dynamic orderId,
    required String status,
  }) async {
    _requireAdminSession();
    final result = await client
        .from('Penjualan')
        .update({'status': status})
        .eq('id_transaksi', orderId)
        .select('id_transaksi')
        .maybeSingle();
    if (result == null) {
      throw StateError(
        'Pesanan tidak ditemukan atau akses untuk mengubah status ditolak.',
      );
    }
  }

  static Future<Map<String, dynamic>?> findOrder({
    required String orderCode,
    required String whatsapp,
  }) async {
    final normalizedWhatsapp = normalizeWhatsapp(whatsapp);
    final orderId = _parseId(orderCode);
    final row = await client
        .from('Penjualan')
        .select(
          'id_transaksi,nama_customer,whatsapp,alamat,total_bayar,status,Detail_Penjualan(kode_produk,jumlah)',
        )
        .eq('id_transaksi', orderId)
        .eq('whatsapp', normalizedWhatsapp)
        .maybeSingle();
    if (row == null ||
        normalizeWhatsapp(row['whatsapp']?.toString() ?? '') !=
            normalizedWhatsapp) {
      return null;
    }
    return Map<String, dynamic>.from(row);
  }

  static Future<void> deleteReview(String id) async {
    _requireAdminSession();
    final deleted = await client
        .from('Review')
        .delete()
        .eq('id_review', _parseId(id))
        .select('id_review')
        .maybeSingle();
    if (deleted == null) {
      throw StateError('Ulasan tidak ditemukan atau akses hapus ditolak.');
    }
  }

  static String resolveImageUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme
        ? value
        : client.storage.from(storageBucket).getPublicUrl(value);
  }

  static void _requireAdminSession() {
    if (loggedInAdmin.state == null) {
      throw const AuthException(
        'Masuk dengan akun admin sebelum mengelola data toko.',
      );
    }
  }

  static dynamic _parseId(String value) => int.tryParse(value) ?? value;

  static List<Map<String, dynamic>> _maps(dynamic rows) {
    if (rows is! List) {
      throw const FormatException('Data dari Supabase bukan daftar baris.');
    }
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static String normalizeWhatsapp(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '62${digits.substring(1)}';
    if (digits.startsWith('8')) digits = '62$digits';
    return digits;
  }

  static String _extension(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (!const {'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw const FormatException('Gambar harus berformat JPG atau PNG.');
    }
    return extension == 'jpeg' ? 'jpg' : extension;
  }

  static String _imageContentType(String filename) =>
      _extension(filename) == 'png' ? 'image/png' : 'image/jpeg';
}
