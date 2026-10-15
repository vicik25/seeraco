import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../domains/_models/product.dart';
import 'Catalog.Ctrl.dart';
import 'Catalog.Data.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  static const _controller = CatalogCtrl();

  @override
  Widget build(BuildContext context) {
    scheduleCatalogLoad();
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: SeeraColors.pinkDeep,
        title: const Text(
          'Katalog Produk',
          style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => RM.navigate.back()),
        actions: [
          IconButton(
            tooltip: 'Keranjang belanja',
            onPressed: _controller.openCart,
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _CatalogBanner(),
                              const SizedBox(height: 26),
                              const _CollectionsCarousel(),
                              const SizedBox(height: 26),
                              Text(
                                'PILIH GAYA FAVORITMU',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: SeeraColors.ink,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _CategoryFilters(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Produk pilihan untuk harimu',
                                  style: TextStyle(color: SeeraColors.greyMauve, fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showSortMessage(context),
                                icon: const Icon(Icons.sort),
                                label: const Text('Urutkan'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: OnReactive(() {
                            if (isCatalogLoading.state) {
                              return const _CatalogSkeleton();
                            }
                            final products = filteredCatalogProducts;
                            if (products.isEmpty) {
                              return const _CatalogEmpty();
                            }
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 1000
                                    ? 4
                                    : constraints.maxWidth >= 640
                                    ? 3
                                    : 2;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.69,
                                  ),
                                  itemBuilder: (context, index) => _CatalogProductCard(
                                    product: products[index],
                                    onTap: () => _controller.openProduct(products[index]),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSortMessage(BuildContext context) {
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      const SnackBar(content: Text('Pilihan pengurutan segera hadir.'), behavior: SnackBarBehavior.fixed),
    );
  }
}

class _CatalogBanner extends StatelessWidget {
  const _CatalogBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width < 600 ? 148 : 190,
      decoration: BoxDecoration(
        color: SeeraColors.pinkLocker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SeeraColors.pinkSoft, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const _LockerLines(),
          Center(
            child: Text(
              'Katalog Produk',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w900,
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 34 : 50,
                color: Colors.white,
                shadows: const [
                  Shadow(color: SeeraColors.pinkPop, blurRadius: 0, offset: Offset(3, 3)),
                  Shadow(color: SeeraColors.pinkPop, blurRadius: 0, offset: Offset(-3, -3)),
                ],
              ),
            ),
          ),
          const Positioned(top: 14, left: 18, child: Icon(Icons.star_rounded, color: SeeraColors.lemon, size: 30)),
          const Positioned(bottom: 14, right: 20, child: Icon(Icons.star_rounded, color: SeeraColors.lilac, size: 34)),
        ],
      ),
    );
  }
}

class _LockerLines extends StatelessWidget {
  const _LockerLines();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _LockerPainter());
}

class _LockerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final panelWidth = size.width / 3;
    for (var panel = 0; panel < 3; panel++) {
      final left = panel * panelWidth;
      final paint = Paint()..color = panel.isEven ? const Color(0x22FFFFFF) : const Color(0x18D6246E);
      canvas.drawRect(Rect.fromLTWH(left, 0, panelWidth - 2, size.height), paint);
      final vent = Paint()
        ..color = const Color(0x28D6246E)
        ..strokeWidth = 2;
      for (var y = 22.0; y < size.height; y += 30) {
        canvas.drawLine(Offset(left + 12, y), Offset(left + panelWidth - 12, y), vent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CollectionsCarousel extends StatelessWidget {
  const _CollectionsCarousel();

  static const collections = [
    ('OUR COLLECTIONS', 'Warna pastel, dibuat dengan hati', SeeraColors.lilac),
    ('BEST SELLERS', 'Temukan beads yang paling disukai', SeeraColors.lemon),
    ('MADE FOR YOU', 'Pilih detail kecil favoritmu', SeeraColors.skyPastel),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR COLLECTIONS',
          style: TextStyle(color: SeeraColors.ink, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.sizeOf(context).width < 600 ? 180 : 142,
          child: PageView.builder(
            pageSnapping: true,
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: collection.$3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 42, color: SeeraColors.pinkDeep),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection.$1,
                              style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(collection.$2, style: const TextStyle(color: SeeraColors.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters();

  static const controller = CatalogCtrl();

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: catalogCategories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = catalogCategories[index];
            final selected = selectedCatalogCategory.state == category;
            return ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => controller.selectCategory(category),
              selectedColor: SeeraColors.pinkPop,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: selected ? Colors.white : SeeraColors.ink, fontWeight: FontWeight.w700),
              side: BorderSide(color: selected ? SeeraColors.pinkPop : SeeraColors.pinkSoft),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SeeraColors.pinkSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductArtwork(product: product),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: SeeraColors.pinkSoft, borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: SeeraColors.pinkDeep,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w700, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        color: SeeraColors.pinkDeep,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFE5A700)),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating} (${product.reviewCount})',
                          style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat katalog produk',
      liveRegion: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 640 ? 2 : 3;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.69,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(color: SeeraColors.pinkSoft, borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: SeeraColors.lilac, size: 44),
          SizedBox(height: 12),
          Text(
            'Belum ada yang cocok, coba kata kunci lain ya',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.greyMauve),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return 'Rp$formatted';
}
