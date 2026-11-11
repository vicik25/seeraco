import 'package:flutter/material.dart';

import 'seera_colors.dart';

class SeeraRadius {
  static const card = 28.0;
  static const input = 18.0;
  static const pill = 999.0;
}

class SeeraShadows {
  static const soft = [BoxShadow(color: Color(0x1AC2185B), blurRadius: 30, offset: Offset(0, 10))];

  static const button = [BoxShadow(color: Color(0x4DC2185B), blurRadius: 20, offset: Offset(0, 8))];
}

ThemeData buildSeeraTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: SeeraColors.primary, brightness: Brightness.light).copyWith(
    primary: SeeraColors.primary,
    onPrimary: Colors.white,
    secondary: SeeraColors.buttonPink,
    surface: Colors.white,
    onSurface: SeeraColors.ink,
    outline: SeeraColors.line,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final textTheme = base.textTheme.apply(bodyColor: SeeraColors.ink, displayColor: SeeraColors.ink);
  const stadium = StadiumBorder();

  return base.copyWith(
    scaffoldBackgroundColor: SeeraColors.pinkMist,
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800),
      displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      displaySmall: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: SeeraColors.primary,
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: Color(0x1FC2185B),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x33C2185B),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SeeraRadius.card)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SeeraColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: stadium,
        elevation: 4,
        shadowColor: const Color(0x4DC2185B),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SeeraColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 48),
        shape: stadium,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SeeraColors.primary,
        minimumSize: const Size(44, 48),
        side: const BorderSide(color: SeeraColors.primary, width: 2),
        shape: stadium,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SeeraColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: SeeraColors.mutedText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SeeraRadius.input),
        borderSide: const BorderSide(color: SeeraColors.line, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SeeraRadius.input),
        borderSide: const BorderSide(color: SeeraColors.line, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SeeraRadius.input),
        borderSide: const BorderSide(color: SeeraColors.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: stadium,
      side: const BorderSide(color: SeeraColors.line, width: 2),
      backgroundColor: Colors.white,
      selectedColor: SeeraColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: SeeraColors.ink),
      secondaryLabelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      height: 72,
      indicatorColor: SeeraColors.pinkSoft,
      indicatorShape: stadium,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: states.contains(WidgetState.selected) ? SeeraColors.primary : SeeraColors.mutedText,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) =>
            IconThemeData(color: states.contains(WidgetState.selected) ? SeeraColors.primary : SeeraColors.mutedText),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SeeraColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? SeeraColors.primary : null,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    dividerTheme: const DividerThemeData(color: SeeraColors.line),
  );
}

class SeeraGradientButton extends StatelessWidget {
  const SeeraGradientButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SeeraRadius.pill);
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SeeraColors.buttonPink, SeeraColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: SeeraShadows.button,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
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
