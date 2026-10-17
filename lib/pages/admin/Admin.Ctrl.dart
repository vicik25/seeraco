import 'package:image_picker/image_picker.dart';

import '../../data/seera_supabase.dart';
import '../../domains/_models/product_review.dart';
import '../catalog/Catalog.Data.dart';
import '../payment/Payment.Data.dart';
import 'Admin.Data.dart';

class AdminCtrl {
  const AdminCtrl();

  Future<void> refresh() => loadStoreData(refresh: true);

  Future<void> refreshStoreSettings() async {
    storePaymentSettingsError.state = null;
    try {
      storePaymentSettings.state = await SeeraSupabase.fetchStoreSettings();
    } catch (error) {
      storePaymentSettingsError.state = error.toString();
      rethrow;
    }
  }

  Future<void> saveStoreBankDetails({
    required String bankName,
    required String accountNumber,
  }) async {
    await SeeraSupabase.updateStoreBankDetails(
      bankName: bankName,
      accountNumber: accountNumber,
    );
    await refreshStoreSettings();
  }

  Future<bool> selectAndUploadStoreQris() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return false;
    final extension = file.name.split('.').last.toLowerCase();
    if (!const {'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw const FormatException('Gambar QRIS harus berformat JPG atau PNG.');
    }
    if (await file.length() > 5 * 1024 * 1024) {
      throw const FormatException('Ukuran gambar QRIS maksimal 5 MB.');
    }
    final url = await SeeraSupabase.uploadStoreQris(file);
    storePaymentSettings.state = {
      ...?storePaymentSettings.state,
      'qris_url': url,
    };
    return true;
  }

  Future<void> refreshProducts() async {
    isAdminProductsLoading.state = true;
    adminProductsError.state = null;
    try {
      adminProducts.state = await SeeraSupabase.fetchProductsForAdmin();
    } catch (error) {
      adminProductsError.state = error.toString();
    } finally {
      isAdminProductsLoading.state = false;
    }
  }

  Future<void> refreshOrders() async {
    isAdminOrdersLoading.state = true;
    adminOrdersError.state = null;
    try {
      adminOrders.state = await SeeraSupabase.fetchOrders();
    } catch (error) {
      adminOrdersError.state = error.toString();
    } finally {
      isAdminOrdersLoading.state = false;
    }
  }

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
        parsedCost < 0 ||
        id.trim().isEmpty) {
      throw const FormatException(
        'Kode, nama, kategori, harga, dan HPP harus diisi dengan benar.',
      );
    }
    if (extension != null &&
        !const {'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw const FormatException(
        'Gambar produk harus berformat JPG atau PNG.',
      );
    }
    await SeeraSupabase.saveProduct(
      id: id.trim(),
      name: name.trim(),
      category: category.trim(),
      description: description.trim(),
      price: parsedPrice,
      costPrice: parsedCost,
      marker: marker.trim(),
      image: image,
    );
    await refreshProducts();
  }

  Future<void> deleteProduct(String id) async {
    await SeeraSupabase.deleteProduct(id);
    await refreshProducts();
  }

  Future<void> updateOrderStatus({
    required dynamic orderId,
    required String status,
  }) async {
    await SeeraSupabase.updateOrderStatus(orderId: orderId, status: status);
    await refreshOrders();
  }

  Future<void> deleteReview(ProductReview review) async {
    if (review.id.isEmpty) {
      throw const FormatException('ID ulasan tidak tersedia dari server.');
    }
    await SeeraSupabase.deleteReview(review.id);
    await refresh();
  }
}
