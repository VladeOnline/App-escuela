import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class ExerciseTimerBar extends StatefulWidget {
  const ExerciseTimerBar({super.key, required this.running});
  final bool running;

  @override
  State<ExerciseTimerBar> createState() => _ExerciseTimerBarState();
}

class _ExerciseTimerBarState extends State<ExerciseTimerBar>
    with SingleTickerProviderStateMixin {
  int    _seconds = 0;
  Timer? _timer;

  // Shimmer lento â€” 4 segundos por ciclo
  late final AnimationController _shimmerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(ExerciseTimerBar old) {
    super.didUpdateWidget(old);
    if (!widget.running) {
      _timer?.cancel();
      _shimmerCtrl.stop();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.running && mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  String get _formatted {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _barColor {
    if (_seconds < 300) return AppColors.success;
    if (_seconds < 600) return AppColors.secondary;
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Icon(Icons.timer_outlined, size: 15, color: _barColor.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          _formatted,
          style: TextStyle(
            fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.w600,
            color: _barColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(AppRadius.full),
            child: SizedBox(
              height: 5,
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _ShimmerBarPainter(
                    progress: _shimmerCtrl.value,
                    color: _barColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ShimmerBarPainter extends CustomPainter {
  const _ShimmerBarPainter({required this.progress, required this.color});
  final double progress;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo de la barra más oscuro
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(99),
      ),
      Paint()..color = color.withValues(alpha: 0.35),
    );

    // Shimmer â€” franja blanca suave que viaja lentamente izq â†’ der
    final shimmerW = size.width * 0.25;
    final x = progress * (size.width + shimmerW) - shimmerW;
    final shimmerRect = Rect.fromLTWH(x, 0, shimmerW, size.height);
    canvas.drawRect(
      shimmerRect,
      Paint()..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(shimmerRect),
    );
  }

  @override
  bool shouldRepaint(_ShimmerBarPainter old) =>
      old.progress != progress || old.color != color;
}

