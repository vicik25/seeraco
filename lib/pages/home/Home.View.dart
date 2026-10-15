import 'package:flutter/material.dart';
import 'package:seeraco/navigator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../domains/_models/product.dart';
import '../../domains/_models/recent_buyer.dart';
import '../../domains/_models/testimonial.dart';
import 'Home.Ctrl.dart';
import 'Home.Data.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _controller = HomeCtrl();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200
        ? 48.0
        : width >= 700
        ? 32.0
        : 16.0;

    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(onCatalog: _controller.openCatalog, onCart: _controller.openCart),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HomeHero(
                      height: width < 700 ? MediaQuery.sizeOf(context).height * 0.68 : 430,
                      onCatalog: _controller.openCatalog,
                    ),
                    const _RibbonDivider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const _SectionTitle(title: 'FAVORIT SEERA'),
                          const SizedBox(height: 20),
                          const _FavoriteProducts(),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: _controller.openCatalog, child: const Text('Lihat Semua Produk')),
                          const SizedBox(height: 28),
                          _ShortcutRow(
                            onAbout: _controller.openAbout,
                            onBuyers: _controller.openBuyers,
                            onCart: _controller.openCart,
                          ),
                          const SizedBox(height: 28),
                          const _PreOrderNote(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const _TestimonialSection(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          const _SectionTitle(title: 'PEMBELI SEERA'),
                          const SizedBox(height: 16),
                          const _RecentBuyers(),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _controller.openBuyers,
                                icon: const Icon(Icons.people_outline),
                                label: const Text('Lihat Semua Pembeli'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _controller.openAbout,
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Tentang Seera'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _controller.openOrderTrack,
                                icon: const Icon(Icons.local_shipping_outlined),
                                label: const Text('Cek Pesanan'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const _HomeFooter(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onCatalog, required this.onCart});

  final VoidCallback onCatalog;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          return Row(
            children: [
              if (isWide)
                IconButton(
                  tooltip: 'Instagram Seera',
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  color: SeeraColors.pinkPop,
                )
              else
                IconButton(
                  tooltip: 'Buka menu',
                  onPressed: onCatalog,
                  icon: const Icon(Icons.menu),
                  color: SeeraColors.ink,
                ),
              Expanded(
                child: Text(
                  'Seera.co_',
                  textAlign: isWide ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(
                    color: SeeraColors.pinkPop,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              if (isWide) TextButton(onPressed: onCatalog, child: const Text('KATALOG')),
              IconButton(
                tooltip: 'Keranjang belanja',
                onPressed: onCart,
                icon: const Icon(Icons.shopping_bag_outlined),
                color: SeeraColors.ink,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.height, required this.onCatalog});

  final double height;
  final VoidCallback onCatalog;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _LockerHeroBackdrop(),
          Positioned(top: 24, left: 20, child: _Star(color: SeeraColors.lemon, size: 34)),
          const Positioned(top: 68, right: 30, child: _Bead(color: SeeraColors.lilac, size: 25)),
          const Positioned(bottom: 56, left: 34, child: _Bead(color: SeeraColors.babyBlueStar, size: 20)),
          Positioned(bottom: 35, right: 28, child: _Star(color: SeeraColors.lilac, size: 28)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Seera.co_',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SeeraColors.pinkPop,
                      fontFamily: 'Georgia',
                      fontSize: MediaQuery.sizeOf(context).width < 380 ? 54 : 76,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -3,
                      shadows: const [
                        Shadow(color: Colors.white, blurRadius: 0, offset: Offset(3, 3)),
                        Shadow(color: Colors.white, blurRadius: 0, offset: Offset(-3, -3)),
                        Shadow(color: Colors.white, blurRadius: 0, offset: Offset(3, -3)),
                        Shadow(color: Colors.white, blurRadius: 0, offset: Offset(-3, 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: SeeraColors.pinkPop,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Make your days colorful #withseera',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: onCatalog,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Lihat Semua Produk'),
                    style: FilledButton.styleFrom(
                      backgroundColor: SeeraColors.pinkDeep,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockerHeroBackdrop extends StatelessWidget {
  const _LockerHeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LockerHeroPainter());
  }
}

class _LockerHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final panelWidth = size.width / 3;
    final colors = [SeeraColors.pinkLocker, const Color(0xFFFF9CC7), const Color(0xFFFF86B8)];
    for (var i = 0; i < colors.length; i++) {
      final rect = Rect.fromLTWH(i * panelWidth, 0, panelWidth - 3, size.height);
      canvas.drawRect(rect, Paint()..color = colors[i]);
      final vent = Paint()
        ..color = const Color(0x1FD6246E)
        ..strokeWidth = 2;
      for (var y = 34.0; y < size.height; y += 38) {
        canvas.drawLine(Offset(rect.left + 12, y), Offset(rect.right - 12, y), vent);
      }
      final seam = Paint()
        ..color = const Color(0x44FFFFFF)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(rect.left + 2, 0), Offset(rect.left + 2, size.height), seam);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RibbonDivider extends StatelessWidget {
  const _RibbonDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      decoration: const BoxDecoration(
        color: SeeraColors.pinkLocker,
        boxShadow: [BoxShadow(color: Color(0x33D6246E), offset: Offset(0, 2), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          13,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.circle,
              size: index.isEven ? 6 : 4,
              color: index.isEven ? Colors.white : SeeraColors.pinkPop,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _RibbonLine()),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: SeeraColors.ink, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ),
        const Expanded(child: _RibbonLine()),
      ],
    );
  }
}

class _RibbonLine extends StatelessWidget {
  const _RibbonLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 5, color: SeeraColors.pinkLocker);
  }
}

class _FavoriteProducts extends StatelessWidget {
  const _FavoriteProducts();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      final products = favoriteProducts.state;
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 640) {
            return SizedBox(
              height: 288,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 208,
                  child: _ProductCard(
                    product: products[index],
                    onTap: () => const HomeCtrl().openProduct(products[index]),
                  ),
                ),
              ),
            );
          }

          final cardWidth = (constraints.maxWidth - 24) / 3;
          return SizedBox(
            height: 288,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < products.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: cardWidth,
                    child: _ProductCard(product: products[i], onTap: () => const HomeCtrl().openProduct(products[i])),
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SeeraColors.pinkMist,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SeeraColors.pinkSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _BeadProductArt(product: product)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${(product.price / 1000).round()}.000',
                      style: const TextStyle(
                        color: SeeraColors.pinkDeep,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
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
}

class _BeadProductArt extends StatelessWidget {
  const _BeadProductArt({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SeeraColors.pinkSoft),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(right: 10, top: 10, child: _Star(color: product.colors.last, size: 18)),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: product.colors.first, width: 13),
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                for (var i = 0; i < product.colors.length; i++)
                  Transform.rotate(
                    angle: i * 2.1,
                    child: Transform.translate(
                      offset: const Offset(0, -42),
                      child: _Bead(color: product.colors[i], size: 17),
                    ),
                  ),
                Icon(Icons.favorite, color: product.colors.last, size: 23),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.onAbout, required this.onBuyers, required this.onCart});

  final VoidCallback onAbout;
  final VoidCallback onBuyers;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      (Icons.info_outline, 'Tentang Seera', onAbout),
      (Icons.people_outline, 'Pembeli Seera', onBuyers),
      (Icons.shopping_bag_outlined, 'Keranjang', onCart),
    ];
    return Row(
      children: [
        for (var i = 0; i < shortcuts.length; i++) ...[
          if (i > 0) Container(height: 48, width: 1, color: SeeraColors.pinkSoft),
          Expanded(
            child: Semantics(
              button: true,
              label: shortcuts[i].$2,
              child: InkWell(
                onTap: shortcuts[i].$3,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(shortcuts[i].$1, color: SeeraColors.pinkDeep, size: 30),
                      const SizedBox(height: 6),
                      Text(shortcuts[i].$2, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreOrderNote extends StatelessWidget {
  const _PreOrderNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        border: Border.all(color: SeeraColors.pinkSoft, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -35,
            child: Container(
              width: 62,
              height: 12,
              decoration: BoxDecoration(color: SeeraColors.pinkPop, borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, color: SeeraColors.pinkDeep),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Semua produk dibuat pre-order. Estimasi tiba 3 sampai 5 hari',
                  style: TextStyle(color: SeeraColors.ink, height: 1.45, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: SeeraColors.pinkDeep,
          child: Text(
            'WHAT THEY SAY ABOUT SEERA?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.7),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: OnReactive(
            () => LayoutBuilder(
              builder: (context, constraints) {
                final reviews = recentTestimonials.state;
                if (constraints.maxWidth < 680) {
                  return SizedBox(
                    height: 202,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          SizedBox(width: 280, child: _TestimonialCard(review: reviews[index])),
                    ),
                  );
                }
                return SizedBox(
                  height: 202,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < reviews.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: _TestimonialCard(review: reviews[i])),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.review});

  final Testimonial review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SeeraColors.pinkSoft),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, size: 18, color: Color(0xFFE5A700)),
              Icon(Icons.star, size: 18, color: Color(0xFFE5A700)),
              Icon(Icons.star, size: 18, color: Color(0xFFE5A700)),
              Icon(Icons.star, size: 18, color: Color(0xFFE5A700)),
              Icon(Icons.star, size: 18, color: Color(0xFFE5A700)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text('“${review.quote}”', style: const TextStyle(color: SeeraColors.ink, height: 1.4)),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: SeeraColors.pinkSoft,
                child: Text(
                  review.initials,
                  style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.displayName,
                    style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                  ),
                  const Text('Customer', style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentBuyers extends StatelessWidget {
  const _RecentBuyers();

  @override
  Widget build(BuildContext context) {
    return OnBuilder(
      listenTo: recentBuyers,
      builder: () {
        final buyers = recentBuyers.state;
        return Column(
          children: [
            for (var i = 0; i < buyers.length; i++) _BuyerRow(buyer: buyers[i], isLast: i == buyers.length - 1),
          ],
        );
      },
    );
  }
}

class _BuyerRow extends StatelessWidget {
  const _BuyerRow({required this.buyer, required this.isLast});

  final RecentBuyer buyer;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isLast ? Colors.white : SeeraColors.pinkMist,
        border: Border(bottom: BorderSide(color: SeeraColors.pinkSoft)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 19,
            backgroundColor: SeeraColors.skyPastel,
            child: Icon(Icons.person_outline, color: SeeraColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyer.displayName,
                  style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${buyer.productName} · ${buyer.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(buyer.date, style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SeeraColors.pinkSoft)),
      ),
      child: const Column(
        children: [
          Text(
            'Seera.co_',
            style: TextStyle(
              color: SeeraColors.pinkPop,
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Make your days colorful #withseera',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      color: color,
      size: size,
      shadows: const [Shadow(color: Colors.white, blurRadius: 1)],
    );
  }
}

class _Bead extends StatelessWidget {
  const _Bead({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x332B1B26), blurRadius: 4, offset: Offset(1, 2))],
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.4),
        child: Container(
          width: size * 0.25,
          height: size * 0.25,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
