import 'package:flutter/material.dart';

import '../../data/seera_supabase.dart';
import '../../domains/_models/product.dart';
import '../theme/seera_colors.dart';

class ProductArtwork extends StatelessWidget {
  const ProductArtwork({required this.product, this.large = false, super.key});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.isNotEmpty) {
      return Image.network(
        SeeraSupabase.resolveImageUrl(product.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _illustration(context),
      );
    }
    return _illustration(context);
  }

  Widget _illustration(BuildContext context) {
    final size = large ? 156.0 : 96.0;
    final colors = product.colors;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, SeeraColors.pinkMist],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.first,
                    width: large ? 17 : 12,
                  ),
                ),
              ),
              Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              for (var i = 0; i < colors.length; i++)
                Transform.rotate(
                  angle: i * 2.1,
                  child: Transform.translate(
                    offset: Offset(0, -size * 0.36),
                    child: _Bead(color: colors[i], size: large ? 20 : 16),
                  ),
                ),
              Icon(
                Icons.favorite_rounded,
                color: colors.last,
                size: large ? 32 : 24,
              ),
            ],
          ),
        ),
      ),
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
      ),
    );
  }
}
