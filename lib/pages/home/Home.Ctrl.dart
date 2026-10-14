import '../../domains/_models/product.dart';
import '../../navigator.dart';
import '../product_detail/ProductDetail.Ctrl.dart';

class HomeCtrl {
  const HomeCtrl();

  void openCatalog() => nav.to('/catalog');

  void openHome() => nav.to('/home');

  void openCart() => nav.to('/cart');

  void openProduct(Product product) {
    const ProductDetailCtrl().selectProduct(product);
    nav.to('/product-detail');
  }
}
