import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data/seera_api.dart';
import '../../domains/_models/product.dart';
import '../../domains/_models/product_review.dart';
import '../../domains/_models/testimonial.dart';

final catalogProducts = RM.inject<List<Product>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final favoriteProducts = RM.inject<List<Product>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final recentTestimonials = RM.inject<List<Testimonial>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final productReviews = RM.inject<List<ProductReview>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);

final selectedCatalogCategory = RM.inject<String>(
  () => 'Semua',
  autoDisposeWhenNotUsed: false,
);
final isCatalogLoading = RM.inject<bool>(
  () => true,
  autoDisposeWhenNotUsed: false,
);
final catalogLoadError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final isReviewsLoading = RM.inject<bool>(
  () => true,
  autoDisposeWhenNotUsed: false,
);
final reviewsLoadError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);

Future<void>? _storeLoad;

Future<void> loadStoreData({bool refresh = false}) {
  if (_storeLoad != null && !refresh) return _storeLoad!;
  _storeLoad = _loadStoreData();
  return _storeLoad!;
}

Future<void> _loadStoreData() async {
  isCatalogLoading.state = true;
  isReviewsLoading.state = true;
  catalogLoadError.state = null;
  reviewsLoadError.state = null;
  await Future.wait([_loadProducts(), _loadReviews()]);
  isCatalogLoading.state = false;
  isReviewsLoading.state = false;
}

Future<void> _loadProducts() async {
  try {
    final rows = await SeeraApi.getList('get_produk.php');
    final products = rows
        .map(Product.fromJson)
        .where((product) => product.name.isNotEmpty)
        .toList(growable: false);
    catalogProducts.state = products;
    favoriteProducts.state = products.take(3).toList(growable: false);
    if (!catalogCategories.contains(selectedCatalogCategory.state)) {
      selectedCatalogCategory.state = 'Semua';
    }
  } catch (error) {
    catalogLoadError.state = error.toString();
  }
}

Future<void> _loadReviews() async {
  try {
    final rows = await SeeraApi.getList('get_review.php');
    final reviews = rows
        .map(ProductReview.fromJson)
        .where((review) => review.comment.isNotEmpty)
        .toList(growable: false);
    productReviews.state = reviews;
    recentTestimonials.state = reviews
        .take(6)
        .map(
          (review) => Testimonial(
            quote: review.comment,
            displayName: review.customerName.isEmpty
                ? 'Pelanggan Seera'
                : review.customerName,
            initials: review.customerName.isEmpty
                ? 'S'
                : review.customerName.substring(0, 1).toUpperCase(),
            rating: review.rating,
            productName: review.productName,
          ),
        )
        .toList(growable: false);
  } catch (error) {
    reviewsLoadError.state = error.toString();
  }
}

List<String> get catalogCategories {
  final categories =
      catalogProducts.state
          .map((product) => product.category)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return ['Semua', ...categories];
}

List<Product> get filteredCatalogProducts {
  final category = selectedCatalogCategory.state;
  if (category == 'Semua') return catalogProducts.state;
  return catalogProducts.state
      .where((product) => product.category == category)
      .toList(growable: false);
}
