import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/cart_item.dart';
import '../../navigator.dart';
import 'Cart.Data.dart';

class CartCtrl {
  const CartCtrl();

  void changeQuantity(CartItem item, int delta) {
    final items = [...cartItems.state];
    final index = items.indexWhere(
      (current) => current.product.id == item.product.id && current.variant == item.variant,
    );
    if (index == -1) {
      throw StateError('Item tidak ditemukan di keranjang.');
    }
    final nextQuantity = items[index].quantity + delta;
    if (nextQuantity < 1 || nextQuantity > 99) return;
    items[index] = items[index].copyWith(quantity: nextQuantity);
    cartItems.state = items;
  }

  void removeItem(CartItem item) {
    cartItems.state = cartItems.state
        .where((current) => current.product.id != item.product.id || current.variant != item.variant)
        .toList();
  }

  void openCatalog() => nav.to('/catalog');

  void continueToCheckout(BuildContext context) {
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      const SnackBar(content: Text('Checkout akan segera hadir.'), behavior: SnackBarBehavior.fixed),
    );
  }
}
