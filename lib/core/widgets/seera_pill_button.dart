import 'package:flutter/material.dart';

import '../theme/seera_colors.dart';

class SeeraPillButton extends StatelessWidget {
  const SeeraPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.light = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? SeeraColors.pinkDeep : Colors.white;
    final background = light ? Colors.white : SeeraColors.pinkDeep;
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      foregroundColor: WidgetStatePropertyAll(
        outlined ? (light ? Colors.white : SeeraColors.pinkDeep) : foreground,
      ),
      backgroundColor: WidgetStatePropertyAll(
        outlined ? Colors.transparent : background,
      ),
      side: WidgetStatePropertyAll(
        outlined
            ? BorderSide(color: light ? Colors.white : SeeraColors.pinkDeep)
            : BorderSide.none,
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      elevation: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered) ? 5 : 2,
      ),
      shadowColor: const WidgetStatePropertyAll(SeeraColors.pinkShadow),
    );

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
