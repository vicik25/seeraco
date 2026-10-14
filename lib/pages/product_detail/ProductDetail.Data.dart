import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/product.dart';

const productVariants = [
  'Pink',
  'Purple',
  'Green',
  'Maroon',
  'Blue',
  'Yellow',
];

final selectedProduct = RM.inject<Product?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
final selectedProductVariant = RM.inject<String>(
  () => productVariants.first,
  autoDisposeWhenNotUsed: false,
);
final selectedProductQuantity = RM.inject<int>(
  () => 1,
  autoDisposeWhenNotUsed: false,
);
