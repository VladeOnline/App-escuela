import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_option_card.dart';

/// Ejercicio de verdadero o falso (RF-09, RF-24).
class TrueOrFalseExercise extends StatefulWidget {
  const TrueOrFalseExercise({
    super.key,
    required this.exercise,
    required this.onResult,
    this.onRetry,
    this.onContinue,
  });

  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  @override
  State<TrueOrFalseExercise> createState() => _TrueOrFalseExerciseState();
}

class _TrueOrFalseExerciseState extends State<TrueOrFalseExercise> {
  bool? _selected;
  bool _submitted = false;

  bool get _correct => widget.exercise.content['correctAnswer'] as bool;
  String get _statement => widget.exercise.content['statement'] as String;
  String? get _explanation =>
      widget.exercise.content['explanation'] as String?;
  String? get _passage => widget.exercise.content['passage'] as String?;

  void _answer(bool value) {
    if (_submitted) return;
    setState(() {
      _selected = value;
      _submitted = true;
    });
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: value == _correct,
      submittedAnswer: value.toString(),
    ));
  }

  ExerciseOptionState _stateFor(bool value) {
    if (!_submitted) {
      return _selected == value
          ? ExerciseOptionState.selected
          : ExerciseOptionState.idle;
    }
    if (_correct == value) return ExerciseOptionState.correct;
    if (_selected == value) return ExerciseOptionState.wrong;
    return ExerciseOptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // -- Enunciado / texto de lectura --------------------------------------
      if (_passage != null && _passage!.isNotEmpty) ...[
        _PassageCard(text: _passage!),
        const SizedBox(height: AppSpacing.lg),
      ],

      // -- Afirmación --------------------------------------------------------
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: [
          const Icon(
            Icons.help_outline_rounded,
            size: 36,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _statement,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
        ]),
      ),
      const SizedBox(height: AppSpacing.xl),

      // -- Botones V/F -------------------------------------------------------
      Row(children: [
        Expanded(
          child: _TFButton(
            label: '✓ Verdadero',
            color: AppColors.success,
            state: _stateFor(true),
            onTap: _submitted ? null : () => _answer(true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TFButton(
            label: '✗ Falso',
            color: AppColors.error,
            state: _stateFor(false),
            onTap: _submitted ? null : () => _answer(false),
          ),
        ),
      ]),

      // -- Explicación -------------------------------------------------------
      if (_submitted && _explanation != null) ...[
        const SizedBox(height: AppSpacing.md),
        _ExplanationBanner(text: _explanation!),
      ],

      // -- Botones Reintentar / Continuar ------------------------------------
      if (_submitted) ...[
        const SizedBox(height: AppSpacing.lg),
        _ActionButtons(
          onRetry: widget.onRetry,
          onContinue: widget.onContinue,
        ),
      ],

      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}

// --- Widgets internos --------------------------------------------------------

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Texto de lectura',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            height: 1.7,
          ),
        ),
      ]),
    );
  }
}

class _ExplanationBanner extends StatelessWidget {
  const _ExplanationBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              height: 1.5,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({this.onRetry, this.onContinue});

  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (onRetry != null) ...[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              mouseCursor:
                  const WidgetStatePropertyAll(SystemMouseCursors.click),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      if (onContinue != null)
        Expanded(
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Continuar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              mouseCursor:
                  const WidgetStatePropertyAll(SystemMouseCursors.click),
            ),
          ),
        ),
    ]);
  }
}

// --- Botón V/F con hover y animación -----------------------------------------

class _TFButton extends StatefulWidget {
  const _TFButton({
    required this.label,
    required this.color,
    required this.state,
    required this.onTap,
  });

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
        ExerciseOptionState.idle =>
          _hovered ? widget.color.withValues(alpha: 0.1) : Colors.white,
        ExerciseOptionState.selected => widget.color.withValues(alpha: 0.15),
        ExerciseOptionState.correct => AppColors.success.withValues(alpha: 0.15),
        ExerciseOptionState.wrong => AppColors.error.withValues(alpha: 0.12),
      };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 80,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.all(AppRadius.xl),
            border: Border.all(
              color: widget.color.withValues(alpha: 
                widget.state != ExerciseOptionState.idle ? 0.8 : 0.35,
              ),
              width: 2,
            ),
            boxShadow: widget.state == ExerciseOptionState.correct
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

