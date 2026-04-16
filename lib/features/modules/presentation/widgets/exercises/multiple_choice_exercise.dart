import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

/// Ejercicio de selección múltiple (RF-09, RF-24).
///
/// Muestra un texto de contexto (opcional), una pregunta y 4 opciones.
/// Bloquea la selección una vez respondido y muestra feedback visual.
class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<MultipleChoiceExercise> createState() =>
      _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  int? _selected;
  bool _answered = false;

  Map<String, dynamic> get _content => widget.exercise.content;

  void _onSelect(int index) {
    if (_answered) return;

    final isCorrect = index == (_content['correctIndex'] as int);
    setState(() {
      _selected = index;
      _answered = true;
    });

    widget.onResult(ExerciseResult(
      exerciseId: widget.exercise.id,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.exercise.points : 0,
      completedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final options = List<String>.from(_content['options'] as List);
    final correctIndex = _content['correctIndex'] as int;
    final passage = _content['passage'] as String?;
    final explanation = _content['explanation'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de contexto opcional
        if (passage != null) ...[
          _PassageCard(text: passage),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Pregunta
        Text(
          _content['question'] as String,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),

        // Opciones
        ...options.asMap().entries.map((entry) {
          final i = entry.key;
          final option = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _OptionTile(
              label: option,
              index: i,
              selected: _selected == i,
              answered: _answered,
              isCorrect: i == correctIndex,
              onTap: () => _onSelect(i),
            ),
          );
        }),

        // Explicación (solo tras responder)
        if (_answered && explanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          _ExplanationBanner(text: explanation),
        ],
      ],
    );
  }
}

// --- Subwidgets ---------------------------------------------------------------

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Texto de lectura',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  Color _borderColor() {
    if (!answered || !selected) {
      if (answered && isCorrect) return AppColors.success;
      return selected ? AppColors.primary : AppColors.border;
    }
    return isCorrect ? AppColors.success : AppColors.error;
  }

  Color _bgColor() {
    if (!answered) return AppColors.surfaceCard;
    if (isCorrect) return AppColors.success.withValues(alpha: 0.08);
    if (selected && !isCorrect) return AppColors.error.withValues(alpha: 0.08);
    return AppColors.surfaceCard;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: const BorderRadius.all(AppRadius.medium),
          border: Border.all(color: _borderColor(), width: 1.5),
        ),
        child: Row(
          children: [
            // Letra de la opción
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _borderColor().withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _letters[index],
                  style: TextStyle(
                    color: _borderColor(),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Icono de resultado
            if (answered)
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : selected
                        ? Icons.cancel_rounded
                        : null,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 20,
              ),
          ],
        ),
      ),
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
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.info, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.info,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}



