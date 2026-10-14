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
    if (selectedProductQuantity.state < 99) {
      selectedProductQuantity.state++;
    }
  }

  void decreaseQuantity() {
    if (selectedProductQuantity.state > 1) {
      selectedProductQuantity.state--;
    }
  }

  void addToCart(BuildContext context) {
    final product = selectedProduct.state;
    if (product == null) {
      throw StateError('Pilih produk sebelum menambahkannya ke keranjang.');
    }

    final item = CartItem(
      product: product,
      variant: selectedProductVariant.state,
      quantity: selectedProductQuantity.state,
    );
    final items = [...cartItems.state];
    final existingIndex = items.indexWhere(
      (current) => current.product.id == item.product.id && current.variant == item.variant,
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
  }

  void buyNow(BuildContext context) {
    addToCart(context);
    navToCart();
  }

  void navToCart() {
    nav.to('/cart');
  }
}
