import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/cart_item.dart';
import '../../domains/_models/product.dart';
import '../../navigator.dart';
import '../cart/Cart.Data.dart';
import 'ProductDetail.Data.dart';

class ProductDetailCtrl {
  const ProductDetailCtrl();

  void selectProduct(Product product) {
    selectedProduct.state = product;
    selectedProductVariant.state = productVariants.first;
    selectedProductQuantity.state = 1;
  }

  void selectVariant(String variant) {
    if (!productVariants.contains(variant)) {
      throw ArgumentError.value(variant, 'variant', 'Unknown product variant');
    }
    selectedProductVariant.state = variant;
  }

  void increaseQuantity() {
    if (selectedProductQuantity.state < availableQuantity) {
      selectedProductQuantity.state++;
    }
  }

  int get availableQuantity {
    final product = selectedProduct.state;
    final stock = product?.stock;
    if (product == null || stock == null) return 99;
    final inCart = cartItems.state
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (total, item) => total + item.quantity);
    return (stock - inCart).clamp(0, 99).toInt();
  }

  void decreaseQuantity() {
    if (selectedProductQuantity.state > 1) {
      selectedProductQuantity.state--;
    }
  }

  bool addToCart(BuildContext context) {
    final product = selectedProduct.state;
    if (product == null) {
      throw StateError('Pilih produk sebelum menambahkannya ke keranjang.');
    }
    if (selectedProductQuantity.state > availableQuantity) {
      RM.scaffold.context = context;
      RM.scaffold.showSnackBar(
        SnackBar(
          content: Text(
            availableQuantity == 0
                ? 'Stok ${product.name} sedang habis.'
                : 'Stok ${product.name} tersisa $availableQuantity unit.',
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return false;
    }

    final item = CartItem(
      product: product,
      variant: selectedProductVariant.state,
      quantity: selectedProductQuantity.state,
    );
    final items = [...cartItems.state];
    final existingIndex = items.indexWhere(
      (current) =>
          current.product.id == item.product.id &&
          current.variant == item.variant,
    );
    if (existingIndex == -1) {
      items.add(item);
    } else {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: (items[existingIndex].quantity + item.quantity).clamp(1, 99),
      );
    }
    cartItems.state = items;

    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang.'),
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(label: 'Lihat', onPressed: navToCart),
      ),
    );
    return true;
  }

  void buyNow(BuildContext context) {
    if (addToCart(context)) navToCart();
  }

  void navToCart() {
    nav.to('/cart');
  }
}
