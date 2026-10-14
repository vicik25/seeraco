import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/cart_item.dart';

final cartItems = RM.inject<List<CartItem>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);

int get cartSubtotal => cartItems.state.fold(
  0,
  (subtotal, item) => subtotal + item.product.price * item.quantity,
);

int get cartUnitCount =>
    cartItems.state.fold(0, (count, item) => count + item.quantity);
