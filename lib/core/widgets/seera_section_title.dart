import 'package:flutter/material.dart';

import '../theme/seera_colors.dart';

class SeeraSectionTitle extends StatelessWidget {
  const SeeraSectionTitle({
    required this.title,
    this.eyebrow,
    this.light = false,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? Colors.white : SeeraColors.ink;
    return Column(
      children: [
        if (eyebrow != null) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: light
                  ? Colors.white.withValues(alpha: 0.18)
                  : SeeraColors.pinkSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                eyebrow!.toUpperCase(),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
