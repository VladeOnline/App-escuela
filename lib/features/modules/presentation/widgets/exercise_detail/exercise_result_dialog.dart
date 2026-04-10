import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

/// Pop-up animado de resultado. Si acertó: confetti + mensaje eufórico.
/// Si falló: búho triste + mensaje alentador. Los mensajes cambian por grado.
class ExerciseResultDialog extends StatefulWidget {
  const ExerciseResultDialog._({required this.result, required this.exercise});
  final ExerciseResult result;
  final ExerciseEntity exercise;

  static Future<void> show(
    BuildContext context, {
    required ExerciseResult result,
    required ExerciseEntity exercise,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) => ExerciseResultDialog._(result: result, exercise: exercise),
    );
  }

  @override
  State<ExerciseResultDialog> createState() => _ExerciseResultDialogState();
}

class _ExerciseResultDialogState extends State<ExerciseResultDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pointsCtrl;
  late final Animation<int> _pointsAnim;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  bool get _correct => widget.result.isCorrect;
  int get _points => widget.result.pointsEarned;

  @override
  void initState() {
    super.initState();
    _pointsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pointsAnim = IntTween(begin: 0, end: _points).animate(
      CurvedAnimation(parent: _pointsCtrl, curve: Curves.easeOut),
    );
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _bounce = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    if (_correct) _pointsCtrl.forward();
  }

  @override
  void dispose() {
    _pointsCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  // Mensajes según grado y resultado
  String get _title {
    if (_correct) {
      return switch (widget.exercise.difficulty) {
        DifficultyLevel.basic    => '¡Wooow, lo lograste! 🌟',
        DifficultyLevel.intermediate => '¡Excelente trabajo! 🎉',
        DifficultyLevel.advanced => '¡Fantástico, eres genial! 💪',
      };
    }
    return '¡Casi lo tienes! 💙';
  }

  String get _subtitle {
    if (_correct) {
      return switch (widget.exercise.difficulty) {
        DifficultyLevel.basic    => '¡Eres increíblemente inteligente! Sigue así, ¡tú puedes con todo!',
        DifficultyLevel.intermediate => '¡Respondiste súper bien! Se nota que pusiste mucho esfuerzo.',
        DifficultyLevel.advanced => '¡Demostraste que eres muy capaz! Ese esfuerzo vale muchísimo.',
      };
    }
    return '¡No te preocupes! Los errores nos enseñan. ¡Inténtalo de nuevo, tú puedes lograrlo!';
  }

  String get _emoji => _correct ? '🦉' : '🦉';
  Color get _color => _correct ? AppColors.success : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Confetti si acertó
          if (_correct) const _ConfettiLayer(),

          Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              boxShadow: [BoxShadow(color: _color.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Cabecera ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_color.withOpacity(0.15), _color.withOpacity(0.04)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
                  ),
                  child: Column(children: [
                    // Emoji del búho con bounce
                    AnimatedBuilder(
                      animation: _bounce,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _bounce.value),
                        child: Text(_emoji, style: const TextStyle(fontSize: 72)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(_title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: _color)),
                  ]),
                ),

                // ── Cuerpo ──
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    Text(_subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontFamily: 'Nunito', height: 1.55, color: AppColors.textSecondary)),

                    if (_correct) ...[
                      const SizedBox(height: AppSpacing.lg),
                      // Puntos animados
                      AnimatedBuilder(
                        animation: _pointsAnim,
                        builder: (_, __) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: const BorderRadius.all(AppRadius.large),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '+${_pointsAnim.value} puntos',
                              style: const TextStyle(fontSize: 24, fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppColors.secondary),
                            ),
                          ]),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Botones
                    Row(children: [
                      // Reintentar (siempre disponible)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Reintentar', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large)),
                          ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Volver
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Volver', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                          style: FilledButton.styleFrom(
                            backgroundColor: _color,
                            minimumSize: const Size(0, 48),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large)),
                          ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Capa de confetti ───

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer();
  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _ConfettiPainter(progress: _ctrl.value),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static final _rng = Random(42);
  static final _pieces = List.generate(60, (_) => _ConfettiPiece(
    x: _rng.nextDouble(),
    delay: _rng.nextDouble(),
    speed: 0.3 + _rng.nextDouble() * 0.7,
    size: 5 + _rng.nextDouble() * 8,
    color: [
      const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF3B82F6),
      const Color(0xFFEC4899), const Color(0xFF8B5CF6), const Color(0xFFEF4444),
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
      final paint = Paint()..color = p.color.withOpacity(opacity.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotationSpeed);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _ConfettiPiece {
  const _ConfettiPiece({required this.x, required this.delay, required this.speed,
      required this.size, required this.color, required this.rotation, required this.rotationSpeed});
  final double x, delay, speed, size, rotation, rotationSpeed;
  final Color color;
}
