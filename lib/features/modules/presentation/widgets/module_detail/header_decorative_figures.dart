import 'package:flutter/material.dart';

class HeaderDecorativeFigures extends StatelessWidget {
  const HeaderDecorativeFigures({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return ClipRect(
          child: Stack(
            children: [
              // ── Extremo izquierdo ──────────────────────────────────────
              _circle(size: 60, x: -10,       y: -10,       opacity: 0.10),
              _circle(size: 36, x: 44,        y: 12,        opacity: 0.13),
              _circle(size: 22, x: 90,        y: 4,         opacity: 0.08),
              _circle(size: 42, x: 10,        y: h - 28,    opacity: 0.09),
              _circle(size: 24, x: 66,        y: h - 20,    opacity: 0.11),

              // ── Cuarto izquierdo ───────────────────────────────────────
              _circle(size: 38, x: w * 0.16, y: h - 22,  opacity: 0.09),
              _circle(size: 16, x: w * 0.22, y: 6,       opacity: 0.12),

              // ── Centro izquierdo ───────────────────────────────────────────
              _circle(size: 50, x: w * 0.36, y: -18,      opacity: 0.07),
              _circle(size: 20, x: w * 0.42, y: h - 12,   opacity: 0.12),

              // ── Centro exacto ──────────────────────────────────────────────
              _circle(size: 28, x: w * 0.50 - 14, y: -6,  opacity: 0.10),

              // ── Centro derecho ─────────────────────────────────────────────
              _circle(size: 18, x: w * 0.60, y: -4,       opacity: 0.13),
              _circle(size: 46, x: w * 0.65, y: h - 26,   opacity: 0.07),

              // ── Cuarto derecho ─────────────────────────────────────────
              _circle(size: 40, x: w * 0.77, y: 8,       opacity: 0.08),
              _circle(size: 18, x: w * 0.83, y: h - 12,  opacity: 0.12),

              // ── Extremo derecho ────────────────────────────────────────
              _circle(size: 22, x: w - 90,    y: 4,         opacity: 0.08),
              _circle(size: 36, x: w - 52,    y: 10,        opacity: 0.13),
              _circle(size: 58, x: w - 20,    y: -10,       opacity: 0.10),
              _circle(size: 24, x: w - 72,    y: h - 20,    opacity: 0.11),
              _circle(size: 44, x: w - 24,    y: h - 26,    opacity: 0.09),
            ],
          ),
        );
      },
    );
  }

  Widget _circle({
    required double size,
    required double x,
    required double y,
    required double opacity,
  }) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}