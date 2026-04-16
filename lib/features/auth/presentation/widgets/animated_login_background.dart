import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AnimatedLoginBackground extends StatefulWidget {
  const AnimatedLoginBackground({super.key});

  @override
  State<AnimatedLoginBackground> createState() => _AnimatedLoginBackgroundState();
}

class _AnimatedLoginBackgroundState extends State<AnimatedLoginBackground>
    with TickerProviderStateMixin {
  late final List<_FloatingItemController> _items;

  static const _labels = [
    '7 + 2 = 9', 'ABC', 'Hola', '📚', 'A', 'B', 'C',
    '1 + 1', '✏️', 'xyz', '∑', '📖', '🌟', '2 × 3',
    'leer', 'sumar', '🎓', 'abc', '123', '🔢',
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _items = List.generate(_labels.length, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(seconds: 10 + rng.nextInt(12)),
      )..forward(from: rng.nextDouble());
      ctrl.addStatusListener((s) {
        if (s == AnimationStatus.completed) ctrl.repeat();
      });
      return _FloatingItemController(
        controller: ctrl,
        startX: rng.nextDouble(),
        startY: rng.nextDouble(),
        driftX: (rng.nextDouble() - 0.5) * 0.12,
        driftY: -(0.04 + rng.nextDouble() * 0.08),
        fontSize: 11.0 + rng.nextDouble() * 9,
        opacity: 0.035 + rng.nextDouble() * 0.055,
        label: _labels[i],
      );
    });
  }

  @override
  void dispose() {
    for (final c in _items) c.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const _BackgroundBase(),
      const _AmbientLights(),
      ..._items.map((c) => _FloatingLabel(item: c)),
    ]);
  }
}

// --- Fondo base ---

class _BackgroundBase extends StatelessWidget {
  const _BackgroundBase();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Gradiente base
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEFAF8), Color(0xFFF6FDFC), Color(0xFFEDF9F6)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
      // Cuadrícula sutil encima
      CustomPaint(
        painter: _GridPainter(),
        child: const SizedBox.expand(),
      ),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.055)
      ..strokeWidth = 0.8;

    const spacing = 40.0;

    // Líneas verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Líneas horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// --- Luces de ambiente ---

class _AmbientLights extends StatefulWidget {
  const _AmbientLights();

  @override
  State<_AmbientLights> createState() => _AmbientLightsState();
}

class _AmbientLightsState extends State<_AmbientLights>
    with TickerProviderStateMixin {
  late final AnimationController _ctrlA;
  late final AnimationController _ctrlB;
  Animation<double> _pulseA = const AlwaysStoppedAnimation(0);
  Animation<double> _pulseB = const AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();
    _ctrlA = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _ctrlB = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _pulseA = CurvedAnimation(parent: _ctrlA, curve: Curves.easeInOut);
    _pulseB = CurvedAnimation(parent: _ctrlB, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrlA.dispose();
    _ctrlB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseA, _pulseB]),
      builder: (_, __) => Stack(children: [

        // Luz grande superior izquierda â€” teal principal
        Positioned(
          top: -size.height * 0.15,
          left: -size.width * 0.08,
          child: _GlowOrb(
            size: size.width * 0.55 + _pulseA.value * 40,
            color: AppColors.primary,
            opacity: 0.14 + _pulseA.value * 0.06,
          ),
        ),

        // Luz media superior derecha â€” teal claro
        Positioned(
          top: size.height * 0.05,
          right: -size.width * 0.05,
          child: _GlowOrb(
            size: size.width * 0.35 + _pulseB.value * 30,
            color: AppColors.primaryLight,
            opacity: 0.11 + _pulseB.value * 0.05,
          ),
        ),

        // Luz pequeña centro derecha â€” ámbar suave
        Positioned(
          top: size.height * 0.30,
          right: size.width * 0.18,
          child: _GlowOrb(
            size: size.width * 0.18 + _pulseA.value * 20,
            color: AppColors.secondary,
            opacity: 0.09 + _pulseA.value * 0.04,
          ),
        ),

        // Luz grande inferior derecha â€” teal oscuro
        Positioned(
          bottom: -size.height * 0.12,
          right: -size.width * 0.06,
          child: _GlowOrb(
            size: size.width * 0.45 + _pulseB.value * 35,
            color: AppColors.primaryDark,
            opacity: 0.12 + _pulseB.value * 0.05,
          ),
        ),

        // Luz pequeña inferior izquierda â€” teal claro
        Positioned(
          bottom: size.height * 0.08,
          left: size.width * 0.20,
          child: _GlowOrb(
            size: size.width * 0.20 + _pulseA.value * 15,
            color: AppColors.primaryLight,
            opacity: 0.09 + _pulseA.value * 0.04,
          ),
        ),

        // Luz centro izquierda â€” accent violeta sutil
        Positioned(
          top: size.height * 0.55,
          left: size.width * 0.25,
          child: _GlowOrb(
            size: size.width * 0.15 + _pulseB.value * 12,
            color: AppColors.accent,
            opacity: 0.07 + _pulseB.value * 0.03,
          ),
        ),
      ]),
    );
  }
}

/// Orbe de luz con gradiente radial â€” centro opaco, bordes transparentes.
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
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.4),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
  );
}

// --- Letras flotantes ---

class _FloatingItemController {
  const _FloatingItemController({
    required this.controller, required this.startX, required this.startY,
    required this.driftX, required this.driftY, required this.fontSize,
    required this.opacity, required this.label,
  });
  final AnimationController controller;
  final double startX, startY, driftX, driftY, fontSize, opacity;
  final String label;
}

class _FloatingLabel extends StatelessWidget {
  const _FloatingLabel({required this.item});
  final _FloatingItemController item;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: item.controller,
      builder: (context, _) {
        final t    = item.controller.value;
        final size = MediaQuery.of(context).size;
        final y    = ((item.startY + item.driftY * t) % 1.2) - 0.1;
        final x    = item.startX + item.driftX * sin(t * pi * 2);

        return Positioned(
          left: x * size.width,
          top:  y * size.height,
          child: Opacity(
            opacity: item.opacity,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize:   item.fontSize,
                fontWeight: FontWeight.w700,
                color:      AppColors.primaryDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        );
      },
    );
  }
}

