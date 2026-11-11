import 'package:flutter/material.dart';

import '../../domains/_models/product.dart';
import '../theme/seera_colors.dart';
import 'product_artwork.dart';

class SeeraProductCard extends StatefulWidget {
  const SeeraProductCard({
    required this.product,
    required this.onTap,
    this.catalogStyle = false,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;
  final bool catalogStyle;

  @override
  State<SeeraProductCard> createState() => _SeeraProductCardState();
}

class _SeeraProductCardState extends State<SeeraProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: SeeraColors.pinkShadow,
              blurRadius: _hovered ? 22 : 14,
              offset: Offset(0, _hovered ? 10 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(26),
            child: Padding(
              padding: EdgeInsets.all(widget.catalogStyle ? 0 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: widget.catalogStyle
                          ? const BorderRadius.vertical(
                              top: Radius.circular(26),
                            )
                          : BorderRadius.circular(20),
                      child: ProductArtwork(product: widget.product),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      widget.catalogStyle ? 12 : 5,
                      12,
                      widget.catalogStyle ? 12 : 5,
                      widget.catalogStyle ? 10 : 7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: widget.catalogStyle ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SeeraColors.ink,
                            fontFamily: widget.catalogStyle ? 'Baloo2' : null,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rp${(widget.product.price / 1000).round()}.000',
                          style: TextStyle(
                            color: SeeraColors.pinkDeep,
                            fontFamily: widget.catalogStyle ? 'Nunito' : null,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
