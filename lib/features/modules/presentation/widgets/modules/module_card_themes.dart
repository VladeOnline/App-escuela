import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

// ─── Temas visuales ───

enum ModuleCardPattern { bubbles, waves, constellation, crystals, petals, mosaic }

class ModuleCardTheme {
  const ModuleCardTheme({
    required this.bg,
    required this.accent,
    required this.soft,
    required this.pattern,
  });
  final Color bg, accent, soft;
  final ModuleCardPattern pattern;
}

const moduleCardThemes = [
  ModuleCardTheme(bg: Color(0xFFF0FDF8), accent: Color(0xFF0D9488), soft: Color(0xFFCCFBF1), pattern: ModuleCardPattern.bubbles),
  ModuleCardTheme(bg: Color(0xFFFFFBEB), accent: Color(0xFFD97706), soft: Color(0xFFFDE68A), pattern: ModuleCardPattern.waves),
  ModuleCardTheme(bg: Color(0xFFEFF6FF), accent: Color(0xFF3B82F6), soft: Color(0xFFBFDBFE), pattern: ModuleCardPattern.constellation),
  ModuleCardTheme(bg: Color(0xFFFFF1F2), accent: Color(0xFFE11D48), soft: Color(0xFFFFCDD5), pattern: ModuleCardPattern.crystals),
  ModuleCardTheme(bg: Color(0xFFF5F3FF), accent: Color(0xFF7C3AED), soft: Color(0xFFDDD6FE), pattern: ModuleCardPattern.petals),
  ModuleCardTheme(bg: Color(0xFFFFF7ED), accent: Color(0xFFEA580C), soft: Color(0xFFFED7AA), pattern: ModuleCardPattern.mosaic),
];

ModuleCardTheme themeForModule(String id) =>
    moduleCardThemes[id.hashCode.abs() % moduleCardThemes.length];

// ─── Puntos de luz dispersos ───

class DotsPainter extends CustomPainter {
  const DotsPainter({required this.color, required this.seed, required this.shift});
  final Color color;
  final int seed;
  final double shift;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 14; i++) {
      final baseX  = rng.nextDouble() * size.width;
      final baseY  = rng.nextDouble() * size.height;
      final radius = 1.2 + rng.nextDouble() * 2.8;
      final speed  = 0.4 + rng.nextDouble() * 0.8;
      paint.color  = color.withOpacity(0.08 + rng.nextDouble() * 0.16);
      final x = (baseX + shift * size.width * speed) % size.width;
      final y = baseY + sin(shift * 2 * pi + i) * 2.0;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(DotsPainter old) => old.shift != shift || old.color != color;
}

// ─── Patrones decorativos ───

class PatternPainter extends CustomPainter {
  const PatternPainter({required this.pattern, required this.color});
  final ModuleCardPattern pattern;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill   = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round;

    switch (pattern) {
      case ModuleCardPattern.bubbles:
        canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.25), 22, stroke);
        canvas.drawCircle(Offset(size.width * 1.0,  size.height * 0.55), 16, fill);
        canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.90), 10, stroke);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.88), 6, fill..color = color.withOpacity(0.5));

      case ModuleCardPattern.waves:
        for (int i = 0; i < 3; i++) {
          final path = Path();
          final y = size.height * (0.3 + i * 0.28);
          path.moveTo(size.width * 0.3, y);
          path.cubicTo(size.width * 0.55, y - 14, size.width * 0.75, y + 14, size.width * 1.05, y);
          canvas.drawPath(path, stroke..strokeWidth = 2.0 - i * 0.4..color = color.withOpacity(1 - i * 0.2));
        }

      case ModuleCardPattern.constellation:
        final pts = [
          Offset(size.width * 0.6,  size.height * 0.15),
          Offset(size.width * 0.9,  size.height * 0.35),
          Offset(size.width * 0.75, size.height * 0.65),
          Offset(size.width * 0.5,  size.height * 0.85),
          Offset(size.width * 1.0,  size.height * 0.80),
        ];
        final line = Paint()..color = color.withOpacity(0.4)..strokeWidth = 1.0;
        for (int i = 0; i < pts.length - 1; i++) canvas.drawLine(pts[i], pts[i + 1], line);
        for (final p in pts) canvas.drawCircle(p, 3.0, fill);

      case ModuleCardPattern.crystals:
        void drawHex(Offset c, double r, double a) {
          final path = Path();
          for (int i = 0; i < 6; i++) {
            final pt = Offset(c.dx + r * cos(a + i * pi / 3), c.dy + r * sin(a + i * pi / 3));
            i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, stroke..strokeWidth = 1.4);
        }
        drawHex(Offset(size.width * 0.75, size.height * 0.35), 18, 0.2);
        drawHex(Offset(size.width * 0.95, size.height * 0.75), 11, 0.5);
        canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.75), 5, fill);

      case ModuleCardPattern.petals:
        final c = Offset(size.width * 0.82, size.height * 0.55);
        for (int i = 0; i < 5; i++) {
          final a   = i * 2 * pi / 5;
          final tip = Offset(c.dx + 22 * cos(a), c.dy + 22 * sin(a));
          canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy)
              ..quadraticBezierTo(c.dx + 15 * cos(a - 0.5), c.dy + 15 * sin(a - 0.5), tip.dx, tip.dy)
              ..quadraticBezierTo(c.dx + 15 * cos(a + 0.5), c.dy + 15 * sin(a + 0.5), c.dx, c.dy),
            stroke..strokeWidth = 1.3,
          );
        }
        canvas.drawCircle(c, 4, fill);

      case ModuleCardPattern.mosaic:
        for (int xi = 0; xi < 3; xi++) {
          for (int yi = 0; yi < 3; yi++) {
            canvas.save();
            canvas.translate(size.width * (0.42 + xi * 0.22), size.height * (0.15 + yi * 0.32));
            canvas.rotate(0.3 + xi * 0.15 + yi * 0.1);
            final h = 6.0 - xi * 1.2;
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: h * 2, height: h * 2), const Radius.circular(2)),
              fill..color = color.withOpacity(0.3 + xi * 0.15),
            );
            canvas.restore();
          }
        }
    }
  }

  @override
  bool shouldRepaint(PatternPainter old) => old.color != color || old.pattern != pattern;
}
