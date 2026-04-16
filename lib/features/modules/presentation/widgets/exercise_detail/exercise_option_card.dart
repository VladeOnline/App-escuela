import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

enum ExerciseOptionState { idle, selected, correct, wrong }

/// Card de opción reutilizable para selección múltiple.
/// Incluye animación de shake cuando la respuesta es incorrecta.
class ExerciseOptionCard extends StatefulWidget {
  const ExerciseOptionCard({
    super.key,
    required this.letter,
    required this.color,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final Color color;
  final String text;
  final ExerciseOptionState state;
  final VoidCallback? onTap;

  @override
  State<ExerciseOptionCard> createState() => _ExerciseOptionCardState();
}

class _ExerciseOptionCardState extends State<ExerciseOptionCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  late final AnimationController _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
  late final Animation<double> _shake = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));

  @override
  void didUpdateWidget(ExerciseOptionCard old) {
    super.didUpdateWidget(old);
    if (widget.state == ExerciseOptionState.wrong &&
        old.state != ExerciseOptionState.wrong) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Color get _bg => switch (widget.state) {
        ExerciseOptionState.idle     => _hovered ? widget.color.withValues(alpha: 0.07) : Colors.white,
        ExerciseOptionState.selected => widget.color.withValues(alpha: 0.12),
        ExerciseOptionState.correct  => AppColors.success.withValues(alpha: 0.12),
        ExerciseOptionState.wrong    => AppColors.error.withValues(alpha: 0.10),
      };

  Color get _borderColor => switch (widget.state) {
        ExerciseOptionState.idle     => _hovered ? widget.color.withValues(alpha: 0.4) : AppColors.border,
        ExerciseOptionState.selected => widget.color,
        ExerciseOptionState.correct  => AppColors.success,
        ExerciseOptionState.wrong    => AppColors.error,
      };

  IconData? get _trailingIcon => switch (widget.state) {
        ExerciseOptionState.correct => Icons.check_circle_rounded,
        ExerciseOptionState.wrong   => Icons.cancel_rounded,
        _                           => null,
      };

  Color? get _trailingColor => switch (widget.state) {
        ExerciseOptionState.correct => AppColors.success,
        ExerciseOptionState.wrong   => AppColors.error,
        _                           => null,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedBuilder(
        animation: _shake,
        builder: (_, child) => Transform.translate(
          offset: Offset(
            widget.state == ExerciseOptionState.wrong
                ? sin(_shake.value * pi * 4) * 6 * (1 - _shake.value)
                : 0,
            0,
          ),
          child: child,
        ),
        child: MouseRegion(
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: const BorderRadius.all(AppRadius.large),
                border: Border.all(
                    color: _borderColor,
                    width: widget.state != ExerciseOptionState.idle ? 2 : 1.5),
                boxShadow: widget.state == ExerciseOptionState.correct
                    ? [BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4))]
                    : [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                // Badge letra
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: widget.state == ExerciseOptionState.idle
                        ? (_hovered
                            ? widget.color.withValues(alpha: 0.15)
                            : widget.color.withValues(alpha: 0.08))
                        : widget.state == ExerciseOptionState.correct
                            ? AppColors.success
                            : widget.state == ExerciseOptionState.wrong
                                ? AppColors.error
                                : widget.color,
                    borderRadius: const BorderRadius.all(AppRadius.medium),
                  ),
                  child: Center(
                    child: Text(
                      widget.letter,
                      style: TextStyle(
                        fontSize: 14, fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                        color: widget.state == ExerciseOptionState.idle
                            ? (_hovered ? widget.color : widget.color.withValues(alpha: 0.7))
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(widget.text,
                      style: const TextStyle(
                          fontSize: 15, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                ),
                if (_trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(_trailingIcon, color: _trailingColor, size: 22),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}


