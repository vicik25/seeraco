import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../core/widgets/product_artwork.dart';
import '../../core/widgets/seera_pill_button.dart';
import '../../core/widgets/seera_product_card.dart';
import '../../core/widgets/seera_section_title.dart';
import '../../domains/_models/recent_buyer.dart';
import '../../domains/_models/testimonial.dart';
import 'Home.Ctrl.dart';
import 'Home.Data.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _controller = HomeCtrl();

  @override
  Widget build(BuildContext context) {
    loadStoreData();
    return Scaffold(
      backgroundColor: SeeraColors.pinkMist,
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              onCatalog: _controller.openCatalog,
              onReviews: _controller.openReviews,
              onOrderTrack: _controller.openOrderTrack,
              onAbout: _controller.openAbout,
              onCart: _controller.openCart,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HomeHero(onCatalog: _controller.openCatalog, onOrderTrack: _controller.openOrderTrack),
                    const _MarqueeStrip(),
                    _PageContent(
                      onCatalog: _controller.openCatalog,
                      onAbout: _controller.openAbout,
                      onBuyers: _controller.openBuyers,
                      onCart: _controller.openCart,
                      onReviews: _controller.openReviews,
                      onOrderTrack: _controller.openOrderTrack,
                    ),
                    const _TestimonialSection(),
                    _BuyerSection(
                      onBuyers: _controller.openBuyers,
                      onAbout: _controller.openAbout,
                      onOrderTrack: _controller.openOrderTrack,
                      onReviews: _controller.openReviews,
                    ),
                    const _HomeFooter(),
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
  const _HomeHeader({
    required this.onCatalog,
    required this.onReviews,
    required this.onOrderTrack,
    required this.onAbout,
    required this.onCart,
  });

  final VoidCallback onCatalog;
  final VoidCallback onReviews;
  final VoidCallback onOrderTrack;
  final VoidCallback onAbout;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SeeraColors.pinkHeroStart,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                return Row(
                  children: [
                    if (!isWide)
                      PopupMenuButton<String>(
                        tooltip: 'Navigasi',
                        icon: const Icon(Icons.menu_rounded),
                        onSelected: (destination) {
                          switch (destination) {
                            case 'catalog':
                              onCatalog();
                              break;
                            case 'reviews':
                              onReviews();
                              break;
                            case 'orders':
                              onOrderTrack();
                              break;
                            case 'about':
                              onAbout();
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'catalog', child: Text('Katalog')),
                          PopupMenuItem(value: 'reviews', child: Text('Ulasan')),
                          PopupMenuItem(value: 'orders', child: Text('Cek Pesanan')),
                          PopupMenuItem(value: 'about', child: Text('Tentang Seera')),
                        ],
                      ),
                    if (isWide)
                      Image.asset('assets/logo.jpg', height: 32, fit: BoxFit.contain, semanticLabel: 'Logo Seera.co_')
                    else
                      const Text(
                        'Seera.co_',
                        style: TextStyle(color: SeeraColors.pinkDeep, fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    const Spacer(),
                    if (isWide) ...[
                      _HeaderLink(label: 'KATALOG', onPressed: onCatalog),
                      _HeaderLink(label: 'ULASAN', onPressed: onReviews),
                      _HeaderLink(label: 'CEK PESANAN', onPressed: onOrderTrack),
                      _HeaderLink(label: 'TENTANG SEERA', onPressed: onAbout),
                    ],
                    IconButton(
                      tooltip: 'Keranjang belanja',
                      onPressed: onCart,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      color: SeeraColors.pinkDeep,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
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

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: SeeraColors.ink,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
      child: Text(label),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onCatalog, required this.onOrderTrack});

  final VoidCallback onCatalog;
  final VoidCallback onOrderTrack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final height = wide ? 440.0 : 600.0;
        return Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [SeeraColors.pinkHeroStart, SeeraColors.pinkHeroEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(900, 56)),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned(top: 52, right: 65, child: _FloatingOrb(color: SeeraColors.peach, size: 23)),
              const Positioned(bottom: 74, left: 40, child: _FloatingOrb(color: SeeraColors.lilac, size: 31)),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 42 : 24, vertical: 22),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: _HeroCopy(onCatalog: onCatalog, onOrderTrack: onOrderTrack, centered: false),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(flex: 5, child: _HeroProductArtwork()),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(flex: 5, child: _HeroProductArtwork()),
                              _HeroCopy(onCatalog: onCatalog, onOrderTrack: onOrderTrack, centered: true),
                              const SizedBox(height: 22),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onCatalog, required this.onOrderTrack, required this.centered});

  final VoidCallback onCatalog;
  final VoidCallback onOrderTrack;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final alignment = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            child: Text(
              'PRE-ORDER  •  ESTIMASI 3–5 HARI',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 13),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Seera.co_',
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.sizeOf(context).width < 400 ? 52 : 70,
              fontWeight: FontWeight.w900,
              letterSpacing: -3,
              height: 1.05,
              shadows: const [Shadow(color: SeeraColors.pinkDeep, blurRadius: 0, offset: Offset(3, 4))],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: const Text(
            'Make your days colorful #withseera',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        const SizedBox(height: 13),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            'Beads watch dan aksesori manis pilihan Seera — biar harimu makin berwarna.',
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 10,
          runSpacing: 8,
          children: [
            SeeraPillButton(label: 'Lihat Semua Produk', icon: Icons.auto_awesome, onPressed: onCatalog, light: true),
            SeeraPillButton(
              label: 'Cek Pesanan',
              icon: Icons.local_shipping_outlined,
              onPressed: onOrderTrack,
              outlined: true,
              light: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroProductArtwork extends StatelessWidget {
  const _HeroProductArtwork();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      final products = favoriteProducts.state;
      if (products.isEmpty) {
        return const Center(child: Icon(Icons.watch_outlined, color: Colors.white, size: 140));
      }
      return Center(
        child: Transform.rotate(
          angle: -0.07,
          child: Container(
            width: MediaQuery.sizeOf(context).width < 760 ? 196 : 252,
            height: MediaQuery.sizeOf(context).width < 760 ? 192 : 284,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [BoxShadow(color: SeeraColors.pinkShadow, blurRadius: 24, offset: Offset(0, 14))],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ProductArtwork(product: products.first, large: true),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  products.first.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FloatingOrb extends StatelessWidget {
  const _FloatingOrb({required this.color, required this.size});

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
        boxShadow: const [BoxShadow(color: SeeraColors.pinkShadow, blurRadius: 12)],
      ),
    );
  }
}

class _MarqueeStrip extends StatelessWidget {
  const _MarqueeStrip();

  static const _labels = [
    '✦ MAKE YOUR DAYS COLORFUL',
    '✦ #WITHSEERA',
    '✦ BEADS WATCH',
    '✦ SEERA COLLECTION',
    '✦ PRE-ORDER 3–5 HARI',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: SeeraColors.pinkDeep,
        child: SizedBox(
          height: 38,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var copy = 0; copy < 3; copy++)
                  for (final label in _labels)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.onCatalog,
    required this.onAbout,
    required this.onBuyers,
    required this.onCart,
    required this.onReviews,
    required this.onOrderTrack,
  });

  final VoidCallback onCatalog;
  final VoidCallback onAbout;
  final VoidCallback onBuyers;
  final VoidCallback onCart;
  final VoidCallback onReviews;
  final VoidCallback onOrderTrack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 38, 18, 42),
          child: Column(
            children: [
              const SeeraSectionTitle(title: 'Paling banyak dicari', eyebrow: 'Favorit Seera'),
              const SizedBox(height: 24),
              const _FavoriteProducts(),
              const SizedBox(height: 18),
              SeeraPillButton(label: 'Lihat Semua Produk', icon: Icons.arrow_forward_rounded, onPressed: onCatalog),
              const SizedBox(height: 38),
              _ShortcutCards(onAbout: onAbout, onBuyers: onBuyers, onCart: onCart),
              const SizedBox(height: 24),
              _PreOrderBanner(onOrderTrack: onOrderTrack),
              const SizedBox(height: 26),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _TextPill(label: 'Ulasan pelanggan', onTap: onReviews),
                  _TextPill(label: 'Cek pesanan', onTap: onOrderTrack),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteProducts extends StatelessWidget {
  const _FavoriteProducts();

  @override
  Widget build(BuildContext context) {
    return OnReactive(() {
      if (isCatalogLoading.state) {
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(color: SeeraColors.pinkPop)),
        );
      }
      if (catalogLoadError.state != null) {
        return _HomeLoadError(message: catalogLoadError.state!, onRetry: () => loadStoreData(refresh: true));
      }
      final products = favoriteProducts.state;
      if (products.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Text(
            'Produk belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.greyMauve),
          ),
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 500
              ? 2
              : 1;
          final cardHeight = columns == 1 ? 330.0 : 310.0;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: cardHeight,
            ),
            itemBuilder: (context, index) =>
                SeeraProductCard(product: products[index], onTap: () => const HomeCtrl().openProduct(products[index])),
          );
        },
      );
    });
  }
}

class _HomeLoadError extends StatelessWidget {
  const _HomeLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: SeeraColors.greyMauve),
      ),
      TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
    ],
  );
}

class _ShortcutCards extends StatelessWidget {
  const _ShortcutCards({required this.onAbout, required this.onBuyers, required this.onCart});

  final VoidCallback onAbout;
  final VoidCallback onBuyers;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        Icons.favorite_outline_rounded,
        'Tentang Seera',
        'Kenalan sama cerita di balik Seera.co',
        onAbout,
        SeeraColors.pinkPop,
      ),
      (
        Icons.people_alt_outlined,
        'Pembeli Seera',
        'Lihat siapa saja yang sudah kebagian lucu-lucunya',
        onBuyers,
        SeeraColors.lilac,
      ),
      (Icons.shopping_bag_outlined, 'Keranjang', 'Cek isi keranjang sebelum checkout', onCart, SeeraColors.pinkDeep),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 640;
        return Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: vertical ? 0 : 14, height: vertical ? 12 : 0),
              _ExpandedIfNeeded(
                expanded: !vertical,
                child: _ShortcutCard(
                  icon: cards[i].$1,
                  title: cards[i].$2,
                  description: cards[i].$3,
                  onTap: cards[i].$4,
                  color: cards[i].$5,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ExpandedIfNeeded extends StatelessWidget {
  const _ExpandedIfNeeded({required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) => expanded ? Expanded(child: child) : child;
}

class _ShortcutCard extends StatefulWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_ShortcutCard> createState() => _ShortcutCardState();
}

class _ShortcutCardState extends State<_ShortcutCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: SeeraColors.pinkShadow, blurRadius: 15, offset: Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(16)),
                    child: Icon(widget.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 11, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: SeeraColors.pinkDeep, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreOrderBanner extends StatelessWidget {
  const _PreOrderBanner({required this.onOrderTrack});

  final VoidCallback onOrderTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [SeeraColors.peach, Color(0xFFFFE6EF)]),
        border: Border.all(color: const Color(0xFFFFC45B)),
        borderRadius: BorderRadius.circular(26),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          return Flex(
            direction: compact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              _ExpandedIfNeeded(
                expanded: !compact,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: Color(0xFFFFC45B), shape: BoxShape.circle),
                      child: const Icon(Icons.hourglass_bottom_rounded, color: SeeraColors.pinkDeep),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Semua produk dibuat pre-order. ',
                              style: TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                              children: [
                                TextSpan(
                                  text: 'Estimasi tiba 3 sampai 5 hari',
                                  style: TextStyle(
                                    color: SeeraColors.greyMauve,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 0 : 14, height: compact ? 14 : 0),
              SeeraPillButton(label: 'Cek Pesanan', icon: Icons.local_shipping_outlined, onPressed: onOrderTrack),
            ],
          );
        },
      ),
    );
  }
}

class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SeeraColors.pinkHeroStart, SeeraColors.pinkDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.elliptical(900, 56), bottom: Radius.elliptical(900, 56)),
      ),
      child: Column(
        children: [
          const SeeraSectionTitle(title: 'WHAT THEY SAY ABOUT SEERA?', eyebrow: 'Ulasan', light: true),
          const SizedBox(height: 26),
          OnReactive(() {
            if (isReviewsLoading.state) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              );
            }
            if (reviewsLoadError.state != null) {
              return _HomeLoadError(message: reviewsLoadError.state!, onRetry: () => loadStoreData(refresh: true));
            }
            final reviews = recentTestimonials.state;
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Belum ada ulasan pelanggan.', style: TextStyle(color: Colors.white)),
              );
            }
            return SizedBox(
              height: 224,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth < 600
                      ? 280.0
                      : constraints.maxWidth < 980
                      ? 310.0
                      : 330.0;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => SizedBox(
                      width: cardWidth,
                      child: _TestimonialCard(review: reviews[index]),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.review});

  final Testimonial review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x1F2B1B26), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                Icon(
                  star <= review.rating ? Icons.star_rounded : Icons.star_outline,
                  size: 18,
                  color: const Color(0xFFFFB52E),
                ),
              const Spacer(),
              const Icon(Icons.format_quote_rounded, color: SeeraColors.pinkSoft, size: 25),
            ],
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Text(
              '“${review.quote}”',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: SeeraColors.ink, height: 1.45, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: SeeraColors.pinkSoft,
                child: Text(
                  review.initials,
                  style: const TextStyle(color: SeeraColors.pinkDeep, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      review.productName.isEmpty ? 'Produk Seera' : review.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyerSection extends StatelessWidget {
  const _BuyerSection({
    required this.onBuyers,
    required this.onAbout,
    required this.onOrderTrack,
    required this.onReviews,
  });

  final VoidCallback onBuyers;
  final VoidCallback onAbout;
  final VoidCallback onOrderTrack;
  final VoidCallback onReviews;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 44, 18, 40),
          child: Column(
            children: [
              const SeeraSectionTitle(title: 'Mereka sudah kebagian', eyebrow: 'Pembeli Seera'),
              const SizedBox(height: 24),
              const _RecentBuyers(),
              const SizedBox(height: 18),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                alignment: WrapAlignment.center,
                children: [
                  _TextPill(label: 'Lihat Semua Pembeli', onTap: onBuyers),
                  _TextPill(label: 'Tentang Seera', onTap: onAbout),
                  _TextPill(label: 'Cek Pesanan', onTap: onOrderTrack),
                  _TextPill(label: 'Ulasan', onTap: onReviews),
                ],
              ),
            ],
          ),
        ),
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
        if (buyers.isEmpty) {
          return const Text('Belum ada pembeli yang ditampilkan.', style: TextStyle(color: SeeraColors.greyMauve));
        }
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: SeeraColors.pinkShadow, blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            children: [
              for (var i = 0; i < buyers.length; i++) _BuyerRow(buyer: buyers[i], isLast: i == buyers.length - 1),
            ],
          ),
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
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: SeeraColors.pinkMist)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: SeeraColors.pinkSoft,
            child: Icon(Icons.person_outline_rounded, color: SeeraColors.pinkDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyer.displayName,
                  style: const TextStyle(color: SeeraColors.ink, fontWeight: FontWeight.w900),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(color: SeeraColors.pinkMist, borderRadius: BorderRadius.circular(20)),
            child: Text(
              buyer.date,
              style: const TextStyle(color: SeeraColors.greyMauve, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextPill extends StatelessWidget {
  const _TextPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: SeeraColors.pinkDeep,
        backgroundColor: Colors.white,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const StadiumBorder(),
        side: const BorderSide(color: SeeraColors.pinkSoft),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0F6), Color(0xFFFFDCEB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Image.asset('assets/logo.jpg', height: 42, fit: BoxFit.contain, semanticLabel: 'Logo Seera.co_'),
          const SizedBox(height: 5),
          const Text(
            'Make your days colorful #withseera',
            textAlign: TextAlign.center,
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _SocialButton(
                tooltip: 'Instagram Seera',
                icon: Icons.camera_alt_outlined,
                onPressed: () => const HomeCtrl().openExternal(context, HomeCtrl.instagramUrl),
              ),
              _SocialButton(
                tooltip: 'Toko Seera di Shopee',
                icon: Icons.shopping_bag_outlined,
                onPressed: () => const HomeCtrl().openExternal(context, HomeCtrl.shopeeUrl),
              ),
              _SocialButton(
                tooltip: 'Tanya Seera via WhatsApp',
                icon: Icons.chat_outlined,
                onPressed: () => const HomeCtrl().openExternal(context, HomeCtrl.whatsappUrl),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => const HomeCtrl().openAdmin(),
            icon: const Icon(Icons.admin_panel_settings_outlined, size: 17),
            label: const Text('Panel Admin'),
            style: TextButton.styleFrom(foregroundColor: SeeraColors.greyMauve, minimumSize: const Size(44, 44)),
          ),
          const SizedBox(height: 2),
          const Text(
            '© 2026 Seera.co  •  Made with love',
            style: TextStyle(color: SeeraColors.greyMauve, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: Colors.white,
      style: IconButton.styleFrom(backgroundColor: SeeraColors.pinkDeep, minimumSize: const Size(44, 44)),
    );
  }
}
