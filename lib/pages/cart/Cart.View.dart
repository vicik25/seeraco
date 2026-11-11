import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../core/widgets/seera_pill_button.dart';
import '../../domains/_models/cart_item.dart';
import 'Cart.Ctrl.dart';
import 'Cart.Data.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  static const _controller = CartCtrl();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Nunito'),
      ),
      child: Scaffold(
        backgroundColor: SeeraColors.pinkMist,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: SeeraColors.pinkDeep,
          title: OnReactive(
            () => Text(
              'Keranjang ($cartUnitCount)',
              style: const TextStyle(
                color: SeeraColors.pinkDeep,
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => RM.navigate.back(),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => OnReactive(() {
            final items = cartItems.state;
            if (items.isEmpty) {
              return _EmptyCart(onBrowse: _controller.openCatalog);
            }
            return Center(
              child: SizedBox(
                width: screenWidth < 920 ? screenWidth : 920,
                height: constraints.maxHeight,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _CartContents(
                      items: items,
                      onChangeQuantity: _controller.changeQuantity,
                      onRemove: _controller.removeItem,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        bottomNavigationBar: OnReactive(() {
          if (cartItems.state.isEmpty) return const SizedBox.shrink();
          return _CartSummaryCard(onCheckout: _controller.continueToCheckout);
        }),
      ),
    );
  }
}

class _CartContents extends StatelessWidget {
  const _CartContents({
    required this.items,
    required this.onChangeQuantity,
    required this.onRemove,
  });

  final List<CartItem> items;
  final void Function(CartItem item, int delta) onChangeQuantity;
  final ValueChanged<CartItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _CartItemCard(
            item: items[i],
            onChangeQuantity: onChangeQuantity,
            onRemove: onRemove,
          ),
        ],
        const SizedBox(height: 20),
        const _PreOrderReminder(),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onChangeQuantity,
    required this.onRemove,
  });

  final CartItem item;
  final void Function(CartItem item, int delta) onChangeQuantity;
  final ValueChanged<CartItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: SeeraColors.pinkShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
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
                borderRadius: BorderRadius.circular(18),
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
                  style: const TextStyle(
                    color: SeeraColors.ink,
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Varian: ${item.variant}',
                  style: const TextStyle(
                    color: SeeraColors.greyMauve,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.product.price),
                  style: const TextStyle(
                    color: SeeraColors.pinkDeep,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Baloo2',
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
                      const Text(
                        'Jumlah',
                        style: TextStyle(
                          color: SeeraColors.greyMauve,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ItemQuantity(
                        item: item,
                        onChangeQuantity: onChangeQuantity,
                      ),
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
                      _ItemQuantity(
                        item: item,
                        onChangeQuantity: onChangeQuantity,
                      ),
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
      height: 44,
      decoration: BoxDecoration(
        color: SeeraColors.pinkMist,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Kurangi',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            onPressed: item.quantity > 1
                ? () => onChangeQuantity(item, -1)
                : null,
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
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            onPressed: item.quantity < 99
                ? () => onChangeQuantity(item, 1)
                : null,
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
        borderRadius: BorderRadius.circular(24),
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

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SeeraColors.pinkSoft)),
        boxShadow: [
          BoxShadow(
            color: SeeraColors.pinkShadow,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final total = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total sementara',
                      style: TextStyle(
                        color: SeeraColors.greyMauve,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    OnReactive(
                      () => Text(
                        _formatPrice(cartSubtotal),
                        style: const TextStyle(
                          color: SeeraColors.pinkDeep,
                          fontFamily: 'Baloo2',
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ],
                );
                final checkoutButton = SeeraPillButton(
                  label: 'Lanjut ke Checkout',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onCheckout,
                );
                if (constraints.maxWidth < 440) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      total,
                      const SizedBox(height: 8),
                      checkoutButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: total),
                    const SizedBox(width: 16),
                    SizedBox(width: 280, child: checkoutButton),
                  ],
                );
              },
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
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: SeeraColors.pinkSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: SeeraColors.pinkDeep,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjangmu masih kosong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SeeraColors.ink,
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk, temukan aksesori manik favoritmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SeeraColors.greyMauve),
            ),
            const SizedBox(height: 20),
            SeeraPillButton(
              label: 'Lihat Produk',
              icon: Icons.auto_awesome,
              onPressed: onBrowse,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp$formatted';
}
