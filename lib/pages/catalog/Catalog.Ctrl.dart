import '../../domains/_models/product.dart';
import '../../navigator.dart';
import '../product_detail/ProductDetail.Ctrl.dart';
import 'Catalog.Data.dart';

class CatalogCtrl {
  const CatalogCtrl();

  void selectCategory(String category) {
    selectedCatalogCategory.state = category;
  }

  void openProduct(Product product) {
    ProductDetailCtrl().selectProduct(product);
    nav.to('/product-detail');
  }

  void openCart() => nav.to('/cart');
}
