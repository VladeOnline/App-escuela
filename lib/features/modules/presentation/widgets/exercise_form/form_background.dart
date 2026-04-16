import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

/// Fondo animado con orbes y grid. Idéntico al de StudentFormPage.
class ExFormBackground extends StatefulWidget {
  const ExFormBackground({super.key});

  @override
  State<ExFormBackground> createState() => _ExFormBackgroundState();
}

class _ExFormBackgroundState extends State<ExFormBackground> with TickerProviderStateMixin {
  late final AnimationController _ctrlA =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  late final AnimationController _ctrlB =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat(reverse: true);
  late final Animation<double> _pulseA = CurvedAnimation(parent: _ctrlA, curve: Curves.easeInOut);
  late final Animation<double> _pulseB = CurvedAnimation(parent: _ctrlB, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrlA.dispose();
    _ctrlB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEFAF8), Color(0xFFF6FDFC), Color(0xFFEDF9F6)],
          ),
        ),
      ),
      CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
      AnimatedBuilder(
        animation: Listenable.merge([_pulseA, _pulseB]),
        builder: (_, __) => Stack(children: [
          Positioned(top: -s.height * 0.15, left: -s.width * 0.08,    child: _GlowOrb(size: s.width * 0.55 + _pulseA.value * 40, color: AppColors.primary,      opacity: 0.14 + _pulseA.value * 0.06)),
          Positioned(top: s.height * 0.05,  right: -s.width * 0.05,   child: _GlowOrb(size: s.width * 0.35 + _pulseB.value * 30, color: AppColors.primaryLight,  opacity: 0.11 + _pulseB.value * 0.05)),
          Positioned(bottom: -s.height * 0.12, right: -s.width * 0.06, child: _GlowOrb(size: s.width * 0.45 + _pulseB.value * 35, color: AppColors.primaryDark,  opacity: 0.12 + _pulseB.value * 0.05)),
          Positioned(bottom: s.height * 0.08, left: s.width * 0.20,   child: _GlowOrb(size: s.width * 0.20 + _pulseA.value * 15, color: AppColors.primaryLight,  opacity: 0.09 + _pulseA.value * 0.04)),
        ]),
      ),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary.withValues(alpha: 0.055)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: opacity * 0.4), color.withValues(alpha: 0)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
}


