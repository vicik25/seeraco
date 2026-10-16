import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/product.dart';
import '../../navigator.dart';
import '../catalog/Catalog.Data.dart';
import 'ProductDetail.Ctrl.dart';
import 'ProductDetail.Data.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  static const _controller = ProductDetailCtrl();

  @override
  Widget build(BuildContext context) {
    loadStoreData();
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: SeeraColors.pinkSoft,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            color: SeeraColors.pinkDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => RM.navigate.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Keranjang belanja',
            onPressed: () => nav.to('/cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 1120 ? screenWidth : 1120,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              OnReactive(() {
                final product = selectedProduct.state;
                if (product == null) return const _MissingProduct();
                return Column(
                  children: [
                    _ProductDetails(product: product),
                    _ProductReviews(product: product),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OnReactive(() {
        final product = selectedProduct.state;
        if (product == null) return const SizedBox.shrink();
        return _DetailActions(
          product: product,
          onAdd: () => _controller.addToCart(context),
          onBuy: () => _controller.buyNow(context),
        );
      }),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final image = _ProductGallery(product: product);
        final details = _ProductInformation(product: product);

        if (wide) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: image),
                    const SizedBox(width: 36),
                    Expanded(child: details),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [image, const SizedBox(height: 24), details],
          ),
        );
      },
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 340,
          decoration: BoxDecoration(
            color: SeeraColors.pinkSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SeeraColors.pinkSoft, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: ProductArtwork(product: product, large: true),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => Container(
              width: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: index == 0
                      ? SeeraColors.pinkPop
                      : SeeraColors.pinkSoft,
                  width: index == 0 ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ProductArtwork(product: product),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductReviews extends StatelessWidget {
  const _ProductReviews({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      final reviews = productReviews.state
          .where(
            (review) =>
                review.productName.toLowerCase() == product.name.toLowerCase(),
          )
          .toList(growable: false);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ulasan pelanggan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SeeraColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (isReviewsLoading.state)
              const Center(
                child: CircularProgressIndicator(color: SeeraColors.pinkPop),
              )
            else if (reviewsLoadError.state != null)
              Text(
                reviewsLoadError.state!,
                style: const TextStyle(color: SeeraColors.greyMauve),
              )
            else if (reviews.isEmpty)
              const Text(
                'Belum ada ulasan untuk produk ini.',
                style: TextStyle(color: SeeraColors.greyMauve),
              )
            else
              for (final review in reviews)
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (var star = 1; star <= 5; star++)
                              Icon(
                                star <= review.rating
                                    ? Icons.star
                                    : Icons.star_outline,
                                color: const Color(0xFFE5A700),
                                size: 18,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                review.customerName.isEmpty
                                    ? 'Pelanggan Seera'
                                    : review.customerName,
                                style: const TextStyle(
                                  color: SeeraColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.comment),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      );
    });
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beranda  /  Katalog  /  ${product.name}',
          style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: SeeraColors.pinkSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: SeeraColors.pinkDeep,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: SeeraColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFE5A700), size: 19),
            const SizedBox(width: 4),
            Text(
              '${product.rating} (${product.reviewCount} ulasan)',
              style: const TextStyle(color: SeeraColors.greyMauve),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _formatPrice(product.price),
          style: const TextStyle(
            color: SeeraColors.pinkDeep,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 12),
        Text(product.description, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 24),
        const Text(
          'PILIH WARNA',
          style: TextStyle(
            color: SeeraColors.ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 10),
        const _VariantPicker(),
        const SizedBox(height: 24),
        const Text(
          'JUMLAH',
          style: TextStyle(
            color: SeeraColors.ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 10),
        const _QuantitySelector(),
        const SizedBox(height: 24),
        const _PreOrderNote(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker();

  static const controller = ProductDetailCtrl();
  static const colors = {
    'Pink': SeeraColors.pinkPop,
    'Purple': SeeraColors.lilac,
    'Green': Color(0xFF78B89A),
    'Maroon': Color(0xFF9B3B5C),
    'Blue': SeeraColors.babyBlueStar,
    'Yellow': SeeraColors.lemon,
  };

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final variant in productVariants)
            ChoiceChip(
              label: Text(variant),
              selected: selectedProductVariant.state == variant,
              onSelected: (_) => controller.selectVariant(variant),
              selectedColor: SeeraColors.pinkSoft,
              backgroundColor: Colors.white,
              avatar: CircleAvatar(
                backgroundColor: colors[variant] ?? SeeraColors.pinkPop,
              ),
              labelStyle: const TextStyle(
                color: SeeraColors.ink,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selectedProductVariant.state == variant
                    ? SeeraColors.pinkPop
                    : SeeraColors.pinkSoft,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector();

  static const controller = ProductDetailCtrl();

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SeeraColors.pinkSoft),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Kurangi jumlah',
              onPressed: selectedProductQuantity.state > 1
                  ? controller.decreaseQuantity
                  : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${selectedProductQuantity.state}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Tambah jumlah',
              onPressed: selectedProductQuantity.state < 99
                  ? controller.increaseQuantity
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreOrderNote extends StatelessWidget {
  const _PreOrderNote();

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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Produk pre-order, estimasi tiba 3 sampai 5 hari. Bayar maksimal 24 jam setelah pesan.',
              style: TextStyle(color: SeeraColors.ink, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.product,
    required this.onAdd,
    required this.onBuy,
  });

  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onBuy;

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
                      child: OutlinedButton(
                        onPressed: onAdd,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SeeraColors.pinkDeep,
                          side: const BorderSide(color: SeeraColors.pinkPop),
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Tambah ke Keranjang'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onBuy,
                        style: FilledButton.styleFrom(
                          backgroundColor: SeeraColors.pinkDeep,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Beli Sekarang'),
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

class _MissingProduct extends StatelessWidget {
  const _MissingProduct();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: SeeraColors.greyMauve,
            ),
            const SizedBox(height: 12),
            const Text('Pilih produk dari katalog untuk melihat detailnya.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => nav.to('/catalog'),
              child: const Text('Lihat Katalog'),
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
