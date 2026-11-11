import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/seera_pill_button.dart';
import '../../core/widgets/seera_product_card.dart';
import 'Catalog.Ctrl.dart';
import 'Catalog.Data.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  static const _controller = CatalogCtrl();

  @override
  Widget build(BuildContext context) {
    loadStoreData();
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
          title: const Text(
            'Katalog Produk',
            style: TextStyle(
              color: SeeraColors.pinkDeep,
              fontFamily: 'Baloo2',
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _CatalogBanner(),
                                const SizedBox(height: 20),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Koleksi Seera',
                                      style: TextStyle(
                                        color: SeeraColors.pinkDeep,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pilih gaya favoritmu',
                                      style: TextStyle(
                                        color: SeeraColors.ink,
                                        fontFamily: 'Baloo2',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                                    style: TextStyle(
                                      color: SeeraColors.greyMauve,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SeeraPillButton(
                                  label: 'Urutkan',
                                  icon: Icons.sort_rounded,
                                  outlined: true,
                                  onPressed: () => _showSortMessage(context),
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
                              if (catalogLoadError.state != null) {
                                return _CatalogLoadError(
                                  message: catalogLoadError.state!,
                                  onRetry: () => loadStoreData(refresh: true),
                                );
                              }
                              final products = filteredCatalogProducts;
                              if (products.isEmpty) {
                                return const _CatalogEmpty();
                              }
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns = _catalogColumns(
                                    constraints.maxWidth,
                                  );
                                  final cardExtent = _catalogCardExtent(
                                    constraints.maxWidth,
                                    columns,
                                  );
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent: cardExtent,
                                        ),
                                    itemBuilder: (context, index) =>
                                        SeeraProductCard(
                                          product: products[index],
                                          catalogStyle: true,
                                          onTap: () => _controller.openProduct(
                                            products[index],
                                          ),
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
      ),
    );
  }

  static void _showSortMessage(BuildContext context) {
    RM.scaffold.context = context;
    RM.scaffold.showSnackBar(
      const SnackBar(
        content: Text('Pilihan pengurutan segera hadir.'),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}

class _CatalogBanner extends StatelessWidget {
  const _CatalogBanner();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      height: compact ? 150 : 168,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SeeraColors.pinkHeroStart, SeeraColors.pinkHeroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: SeeraColors.pinkShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: compact ? -30 : 36,
            child: Container(
              width: compact ? 130 : 150,
              height: compact ? 130 : 150,
              decoration: const BoxDecoration(
                color: SeeraColors.lilac,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -34,
            right: compact ? 112 : 174,
            child: Container(
              width: compact ? 82 : 94,
              height: compact ? 82 : 94,
              decoration: const BoxDecoration(
                color: SeeraColors.lemon,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 22 : 36,
              vertical: compact ? 14 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'OUR COLLECTIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Katalog Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Baloo2',
                    fontSize: compact ? 28 : 42,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                const _CollectionsCarousel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    return SizedBox(
      height: 38,
      child: PageView.builder(
        pageSnapping: true,
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collection.$1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                collection.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          );
        },
      ),
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
        height: 48,
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
              materialTapTargetSize: MaterialTapTargetSize.padded,
              shape: const StadiumBorder(),
              labelStyle: TextStyle(
                color: selected ? Colors.white : SeeraColors.ink,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: selected ? SeeraColors.pinkPop : SeeraColors.pinkSoft,
              ),
            );
          },
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
          final columns = _catalogColumns(constraints.maxWidth);
          final cardExtent = _catalogCardExtent(constraints.maxWidth, columns);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: cardExtent,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: SeeraColors.pinkSoft,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      ),
    );
  }
}

int _catalogColumns(double width) {
  if (width >= 820) return 5;
  if (width >= 600) return 3;
  return 2;
}

double _catalogCardExtent(double width, int columns) {
  final cardWidth = (width - (columns - 1) * 16) / columns;
  return (cardWidth * 1.6).clamp(250.0, 320.0);
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

class _CatalogLoadError extends StatelessWidget {
  const _CatalogLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: SeeraColors.pinkDeep,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: SeeraColors.greyMauve),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Muat ulang'),
        ),
      ],
    ),
  );
}
