import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/cart_item.dart';
import 'Cart.Ctrl.dart';
import 'Cart.Data.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  static const _controller = CartCtrl();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: OnReactive(
          () => Text(
            'Keranjang ($cartUnitCount)',
            style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
          ),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 800 ? screenWidth : 800,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              OnReactive(() {
                final items = cartItems.state;
                if (items.isEmpty) {
                  return _EmptyCart(onBrowse: _controller.openCatalog);
                }
                return _CartContents(
                  items: items,
                  onChangeQuantity: _controller.changeQuantity,
                  onRemove: _controller.removeItem,
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OnReactive(() {
        if (cartItems.state.isEmpty) return const SizedBox.shrink();
        return _CartCheckoutBar(onCheckout: _controller.continueToCheckout);
      }),
    );
  }
}

class _CartContents extends StatelessWidget {
  const _CartContents({required this.items, required this.onChangeQuantity, required this.onRemove});

  final List<CartItem> items;
  final void Function(CartItem item, int delta) onChangeQuantity;
  final ValueChanged<CartItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _CartItemCard(item: items[i], onChangeQuantity: onChangeQuantity, onRemove: onRemove),
          ],
          const SizedBox(height: 20),
          const _PreOrderReminder(),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.onChangeQuantity, required this.onRemove});

  final CartItem item;
  final void Function(CartItem item, int delta) onChangeQuantity;
  final ValueChanged<CartItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            final artwork = SizedBox(
              width: compact ? 64 : 88,
              height: compact ? 72 : 104,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ProductArtwork(product: item.product),
              ),
            );
            final productInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('Varian: ${item.variant}', style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.product.price),
                  style: const TextStyle(
                    color: SeeraColors.pinkDeep,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            );
            final removeButton = IconButton(
              tooltip: 'Hapus ${item.product.name}',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: EdgeInsets.zero,
              onPressed: () => onRemove(item),
              icon: const Icon(Icons.delete_outline),
              color: SeeraColors.pinkDeep,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      artwork,
                      const SizedBox(width: 8),
                      Expanded(child: productInfo),
                      removeButton,
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Jumlah', style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                      const SizedBox(width: 8),
                      _ItemQuantity(item: item, onChangeQuantity: onChangeQuantity),
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                artwork,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      productInfo,
                      const SizedBox(height: 4),
                      _ItemQuantity(item: item, onChangeQuantity: onChangeQuantity),
                    ],
                  ),
                ),
                removeButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ItemQuantity extends StatelessWidget {
  const _ItemQuantity({required this.item, required this.onChangeQuantity});

  final CartItem item;
  final void Function(CartItem item, int delta) onChangeQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: SeeraColors.pinkMist,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Kurangi',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: item.quantity > 1 ? () => onChangeQuantity(item, -1) : null,
            icon: const Icon(Icons.remove, size: 16),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Tambah',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: item.quantity < 99 ? () => onChangeQuantity(item, 1) : null,
            icon: const Icon(Icons.add, size: 16),
          ),
        ],
      ),
    );
  }
}

class _PreOrderReminder extends StatelessWidget {
  const _PreOrderReminder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        border: Border.all(color: SeeraColors.pinkSoft, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2_outlined, color: SeeraColors.pinkDeep),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ongkir dihitung di langkah berikutnya. Semua produk dibuat pre-order dengan estimasi tiba 3 sampai 5 hari.',
              style: TextStyle(color: SeeraColors.ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartCheckoutBar extends StatelessWidget {
  const _CartCheckoutBar({required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 48,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(
                      child: OnReactive(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total sementara',
                              style: TextStyle(color: SeeraColors.greyMauve, fontSize: 11, height: 1),
                            ),
                            Text(
                              _formatPrice(cartSubtotal),
                              style: const TextStyle(
                                color: SeeraColors.ink,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                fontSize: 14,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onCheckout,
                        style: FilledButton.styleFrom(
                          backgroundColor: SeeraColors.pinkDeep,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Lanjut ke Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(color: SeeraColors.pinkSoft, shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined, size: 54, color: SeeraColors.pinkDeep),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjangmu masih kosong',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: SeeraColors.ink, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk, temukan aksesori manik favoritmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SeeraColors.greyMauve),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: SeeraColors.pinkDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
              child: const Text('Lihat Produk'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return 'Rp$formatted';
}
