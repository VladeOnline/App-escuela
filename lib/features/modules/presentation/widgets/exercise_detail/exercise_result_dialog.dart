import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class ExerciseResultDialog extends StatefulWidget {
  const ExerciseResultDialog._({
    required this.result,
    required this.exercise,
  });

  final ExerciseResult result;
  final ExerciseEntity exercise;

  static Future<bool?> show(
    BuildContext context, {
    required ExerciseResult result,
    required ExerciseEntity exercise,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) {
        final correct = result.isCorrect;
        return Stack(
          children: [
            // Confetti en TODA la pantalla — encima del barrier, detrás del dialog
            if (correct)
              const Positioned.fill(
                child: IgnorePointer(child: _ConfettiLayer()),
              ),
            ExerciseResultDialog._(result: result, exercise: exercise),
          ],
        );
      },
    );
  }

  @override
  State<ExerciseResultDialog> createState() =>
      _ExerciseResultDialogState();
}

class _ExerciseResultDialogState extends State<ExerciseResultDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pointsCtrl;
  late final Animation<int> _pointsAnim;

  bool get _correct => widget.result.isCorrect;
  int get _points => widget.result.pointsEarned;
  Color get _color => _correct ? AppColors.success : AppColors.primary;

  @override
  void initState() {
    super.initState();
    _pointsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pointsAnim = IntTween(begin: 0, end: _points).animate(
      CurvedAnimation(parent: _pointsCtrl, curve: Curves.easeOut),
    );
    if (_correct) _pointsCtrl.forward();
  }

  @override
  void dispose() {
    _pointsCtrl.dispose();
    super.dispose();
  }

  String get _title {
    if (_correct) {
      return switch (widget.exercise.difficulty) {
        DifficultyLevel.basic => '¡Wooow, lo lograste!',
        DifficultyLevel.intermediate => '¡Excelente trabajo!',
        DifficultyLevel.advanced => '¡Fantástico, eres genial!',
      };
    }
    return '¡Casi lo tienes!';
  }

  String get _subtitle {
    if (_correct) {
      return switch (widget.exercise.difficulty) {
        DifficultyLevel.basic =>
          '¡Eres increíblemente inteligente! Sigue así, ¡tú puedes con todo!',
        DifficultyLevel.intermediate =>
          '¡Respondiste súper bien! Se nota que pusiste mucho esfuerzo.',
        DifficultyLevel.advanced =>
          '¡Demostraste que eres muy capaz! Ese esfuerzo vale muchísimo.',
      };
    }
    return '¡No te preocupes! Los errores nos enseñan. ¡Inténtalo de nuevo, tú puedes lograrlo!';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Confetti — solo decorativo, no bloquea eventos
          if (_correct)
            const Positioned.fill(
              child: IgnorePointer(child: _ConfettiLayer()),
            ),

          // Card del dialog
          Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xl,
                      AppSpacing.xl, AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _color.withValues(alpha: 0.15),
                        _color.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: AppRadius.xl),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        _correct
                            ? 'assets/images/buho_celebracion.png'
                            : 'assets/images/buho_triste.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: _color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cuerpo
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Nunito',
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      if (_correct) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AnimatedBuilder(
                          animation: _pointsAnim,
                          builder: (_, __) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.secondary
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  const BorderRadius.all(AppRadius.large),
                              border: Border.all(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: AppColors.secondary, size: 28),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '+${_pointsAnim.value} puntos',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              // Reintentar → retorna true
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              icon: const Icon(Icons.replay_rounded,
                                  size: 18),
                              label: const Text('Reintentar',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        AppRadius.large)),
                              ).copyWith(
                                  mouseCursor:
                                      const WidgetStatePropertyAll(
                                          SystemMouseCursors.click)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: FilledButton.icon(
                              // Volver → retorna false
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              icon: const Icon(
                                  Icons.arrow_back_rounded, size: 18),
                              label: const Text('Volver',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700)),
                              style: FilledButton.styleFrom(
                                backgroundColor: _color,
                                minimumSize: const Size(0, 48),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        AppRadius.large)),
                              ).copyWith(
                                  mouseCursor:
                                      const WidgetStatePropertyAll(
                                          SystemMouseCursors.click)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confetti
// ---------------------------------------------------------------------------

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ConfettiPainter(progress: _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});
  final double progress;

  static final _rng = Random(42);
  static final _pieces = List.generate(60, (_) => _ConfettiPiece(
    x: _rng.nextDouble(),
    delay: _rng.nextDouble(),
    speed: 0.3 + _rng.nextDouble() * 0.7,
    size: 5 + _rng.nextDouble() * 8,
    color: [
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
    ][_rng.nextInt(6)],
    rotation: _rng.nextDouble() * 2 * pi,
    rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _pieces) {
      final t = ((progress - p.delay) * p.speed) % 1.0;
      if (t < 0) continue;
      final x = p.x * size.width + sin(t * 2 * pi) * 20;
      final y = -20 + t * (size.height + 40);
      final opacity = t > 0.7 ? 1 - ((t - 0.7) / 0.3) : 1.0;
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotationSpeed);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
  final double x, delay, speed, size, rotation, rotationSpeed;
  final Color color;
}