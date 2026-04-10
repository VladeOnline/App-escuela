import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_option_card.dart';

class TrueOrFalseExercise extends StatefulWidget {
  const TrueOrFalseExercise({super.key, required this.exercise, required this.onResult});
  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<TrueOrFalseExercise> createState() => _TrueOrFalseExerciseState();
}

class _TrueOrFalseExerciseState extends State<TrueOrFalseExercise> {
  bool? _selected;
  bool  _submitted = false;

  bool   get _correct   => widget.exercise.content['correctAnswer'] as bool;
  String get _statement => widget.exercise.content['statement'] as String;

  void _answer(bool value) {
    if (_submitted) return;
    setState(() { _selected = value; _submitted = true; });
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: value == _correct,
    ));
  }

  ExerciseOptionState _stateFor(bool value) {
    if (!_submitted) return _selected == value ? ExerciseOptionState.selected : ExerciseOptionState.idle;
    if (_correct == value) return ExerciseOptionState.correct;
    if (_selected == value) return ExerciseOptionState.wrong;
    return ExerciseOptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Afirmación
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          const Icon(Icons.help_outline_rounded, size: 36, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text(_statement, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w700, height: 1.55)),
        ]),
      ),
      const SizedBox(height: AppSpacing.xl),

      // Botones V/F
      Row(children: [
        Expanded(child: _TFButton(label: '✓ Verdadero', color: AppColors.success,
            state: _stateFor(true), onTap: _submitted ? null : () => _answer(true))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _TFButton(label: '✗ Falso', color: AppColors.error,
            state: _stateFor(false), onTap: _submitted ? null : () => _answer(false))),
      ]),
      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}

// ─── Botón V/F ───

class _TFButton extends StatefulWidget {
  const _TFButton({required this.label, required this.color, required this.state, required this.onTap});
  final String label;
  final Color color;
  final ExerciseOptionState state;
  final VoidCallback? onTap;

  @override
  State<_TFButton> createState() => _TFButtonState();
}

class _TFButtonState extends State<_TFButton> {
  bool _hovered = false;

  Color get _bg => switch (widget.state) {
        ExerciseOptionState.idle     => _hovered ? widget.color.withOpacity(0.1) : Colors.white,
        ExerciseOptionState.selected => widget.color.withOpacity(0.15),
        ExerciseOptionState.correct  => AppColors.success.withOpacity(0.15),
        ExerciseOptionState.wrong    => AppColors.error.withOpacity(0.12),
      };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 80,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.all(AppRadius.xl),
            border: Border.all(
                color: widget.color.withOpacity(widget.state != ExerciseOptionState.idle ? 0.8 : 0.35),
                width: 2),
            boxShadow: widget.state == ExerciseOptionState.correct
                ? [BoxShadow(color: AppColors.success.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Center(
            child: Text(widget.label,
                style: TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                    color: widget.color)),
          ),
        ),
      ),
    );
  }
}
