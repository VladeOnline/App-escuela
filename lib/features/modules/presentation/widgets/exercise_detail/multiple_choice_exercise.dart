import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_option_card.dart';

/// Ejercicio de selección múltiple (RF-09, RF-24).
///
/// Muestra un enunciado de contexto (passage), la pregunta y las opciones.
/// Tras responder aparece la explicación y los botones de acción.
class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({
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
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  int? _selected;
  bool _submitted = false;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _optColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
  ];

  List<String> get _options =>
      (widget.exercise.content['options'] as List).cast<String>();
  int get _correctIndex => widget.exercise.content['correctIndex'] as int;
  String get _question => widget.exercise.content['question'] as String;
  String? get _explanation => widget.exercise.content['explanation'] as String?;
  String? get _passage => widget.exercise.content['passage'] as String?;

  void _submit() {
    if (_selected == null || _submitted) return;
    setState(() => _submitted = true);
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: _selected == _correctIndex,
    ));
  }

  ExerciseOptionState _stateFor(int i) {
    if (!_submitted) {
      return _selected == i ? ExerciseOptionState.selected : ExerciseOptionState.idle;
    }
    if (i == _correctIndex) return ExerciseOptionState.correct;
    if (_selected == i) return ExerciseOptionState.wrong;
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

      // -- Pregunta ----------------------------------------------------------
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
        child: Text(
          _question,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),

      // -- Opciones ----------------------------------------------------------
      ...List.generate(
        _options.length,
        (i) => ExerciseOptionCard(
          letter: i < _letters.length ? _letters[i] : '${i + 1}',
          color: _optColors[i % _optColors.length],
          text: _options[i],
          state: _stateFor(i),
          onTap: _submitted ? null : () => setState(() => _selected = i),
        ),
      ),

      // -- Explicación -------------------------------------------------------
      if (_submitted && _explanation != null) ...[
        const SizedBox(height: AppSpacing.md),
        _ExplanationBanner(text: _explanation!),
      ],

      // -- Botón confirmar (fase answering) ----------------------------------
      if (!_submitted) ...[
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _selected != null ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: widget.exercise.difficulty.color,
            minimumSize: const Size(0, 52),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.large),
            ),
          ).copyWith(
            mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
          child: const Text(
            'Confirmar respuesta',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],

      // -- Botones Reintentar / Continuar (fase reviewing) -------------------
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

