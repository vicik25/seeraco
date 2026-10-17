import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import 'Splash.Ctrl.dart';
import 'Splash.Data.dart';

final splashState = RM.inject<SplashData>(
  () => const SplashData(),
  sideEffects: SideEffects(initState: () => SplashCtrl().start()),
);

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashAnimation();
  }
}

class _SplashAnimation extends StatefulWidget {
  const _SplashAnimation();

  @override
  State<_SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<_SplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) &&
        !_orbitController.isAnimating) {
      _orbitController.repeat();
    } else if (MediaQuery.disableAnimationsOf(context) &&
        _orbitController.isAnimating) {
      _orbitController.stop();
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: SeeraColors.pinkLocker,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final paperWidth = math.min(constraints.maxWidth - 48, 440.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                const _LockerBackdrop(),
                Center(
                  child: SizedBox(
                    width: paperWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (context, child) => CustomPaint(
                            painter: _OrbitPainter(
                              progress: reduceMotion
                                  ? 0
                                  : _orbitController.value,
                            ),
                            child: SizedBox(width: paperWidth, height: 360),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: const _SplashNote(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashNote extends StatelessWidget {
  const _SplashNote();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: math.min(width - 64, 360),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 32),
      decoration: BoxDecoration(
        color: SeeraColors.creamPaper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332B1B26),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 12,
            decoration: BoxDecoration(
              color: SeeraColors.pinkPop,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          Image.asset(
            'assets/logo.jpg',
            width: math.min(width - 104, 280),
            height: width < 380 ? 64 : 78,
            fit: BoxFit.contain,
            semanticLabel: 'Logo Seera.co_',
          ),
          const SizedBox(height: 12),
          const Text(
            'Make your days colorful #withseera',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SeeraColors.pinkDeep,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          OnReactive(
            () => Text(
              splashState.state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SeeraColors.greyMauve,
                fontSize: 12,
                letterSpacing: 0.4,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockerBackdrop extends StatelessWidget {
  const _LockerBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LockerPainter());
  }
}

class _LockerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final panelWidth = size.width / 3;
    final paint = Paint();
    for (var i = 0; i < 3; i++) {
      final panel = Rect.fromLTWH(
        i * panelWidth,
        0,
        panelWidth - 3,
        size.height,
      );
      paint.color = i.isEven ? SeeraColors.pinkLocker : const Color(0xFFFF9BC8);
      canvas.drawRect(panel, paint);

      final ventPaint = Paint()
        ..color = const Color(0x22D6246E)
        ..strokeWidth = 2;
      for (var y = size.height * 0.16; y < size.height * 0.9; y += 32) {
        canvas.drawLine(
          Offset(panel.left + 16, y),
          Offset(panel.right - 16, y),
          ventPaint,
        );
      }
    }
    final lockPaint = Paint()..color = const Color(0xFFB9AAB3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.94, size.height * 0.48, 18, 42),
        const Radius.circular(5),
      ),
      lockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const orbitColors = [
      SeeraColors.lilac,
      SeeraColors.lemon,
      SeeraColors.babyBlueStar,
      SeeraColors.pinkSoft,
      Colors.white,
      SeeraColors.skyPastel,
    ];

    for (var i = 0; i < orbitColors.length; i++) {
      final direction = i.isEven ? 1 : -1;
      final angle = progress * math.pi * 2 * direction + (i * math.pi / 3);
      final radiusX = size.width * (i.isEven ? 0.43 : 0.34);
      final radiusY = size.height * (i.isEven ? 0.39 : 0.31);
      final point = Offset(
        center.dx + math.cos(angle) * radiusX,
        center.dy + math.sin(angle) * radiusY,
      );
      final paint = Paint()..color = orbitColors[i];

      if (i < 3) {
        _drawStar(canvas, point, 12, paint);
      } else {
        canvas.drawCircle(point, i == 4 ? 8 : 11, paint);
        canvas.drawCircle(
          point.translate(-3, -3),
          2.5,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point =
          center +
          Offset(
            math.cos(angle) * (i.isEven ? radius : radius * 0.45),
            math.sin(angle) * (i.isEven ? radius : radius * 0.45),
          );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
