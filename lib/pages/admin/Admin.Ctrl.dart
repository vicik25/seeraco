import 'package:cross_file/cross_file.dart';

import '../../data/seera_api.dart';
import '../../domains/_models/product_review.dart';
import '../catalog/Catalog.Data.dart';

class AdminCtrl {
  const AdminCtrl();

  Future<void> refresh() => loadStoreData(refresh: true);

  Future<void> saveProduct({
    required String id,
    required String name,
    required String category,
    required String description,
    required String price,
    required String costPrice,
    required String marker,
    XFile? image,
  }) async {
    final parsedPrice = int.tryParse(price.trim());
    final parsedCost = int.tryParse(costPrice.trim());
    final extension = image?.name.split('.').last.toLowerCase();
    if (name.trim().isEmpty ||
        category.trim().isEmpty ||
        parsedPrice == null ||
        parsedPrice < 0 ||
        parsedCost == null ||
        parsedCost < 0) {
      throw const FormatException(
        'Nama, kategori, harga, dan HPP harus diisi dengan benar.',
      );
    }
    if (extension != null &&
        !const {'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw const FormatException(
        'Gambar produk harus berformat JPG atau PNG.',
      );
    }
    await SeeraApi.postFields(
      'update_produk.php',
      {
        'id_produk': id,
        'nama_produk': name.trim(),
        'kategori': category.trim(),
        'deskripsi': description.trim(),
        'harga': parsedPrice.toString(),
        'hpp': parsedCost.toString(),
        'penanda': marker.trim(),
      },
      file: image,
      fileField: 'gambar',
    );
    await refresh();
  }

  Future<void> deleteReview(ProductReview review) async {
    if (review.id.isEmpty) {
      throw const FormatException('ID ulasan tidak tersedia dari server.');
    }
    await SeeraApi.postFields('hapus_review.php', {'id_review': review.id});
    await refresh();
  }
}
