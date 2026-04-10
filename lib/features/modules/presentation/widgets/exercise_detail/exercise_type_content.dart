import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'fill_in_blank_exercise.dart';
import 'multiple_choice_exercise.dart';
import 'true_or_false_exercise.dart';

export 'fill_in_blank_exercise.dart';
export 'multiple_choice_exercise.dart';
export 'true_or_false_exercise.dart';

/// Selector de widget según el tipo de ejercicio.
/// Delega el estado de respuesta, reintento y continuación a cada widget hijo.
class ExerciseTypeContent extends StatelessWidget {
  const ExerciseTypeContent({
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
  Widget build(BuildContext context) => switch (exercise.type) {
        ExerciseType.multipleChoice => MultipleChoiceExercise(
            exercise: exercise,
            onResult: onResult,
            onRetry: onRetry,
            onContinue: onContinue,
          ),
        ExerciseType.trueOrFalse => TrueOrFalseExercise(
            exercise: exercise,
            onResult: onResult,
            onRetry: onRetry,
            onContinue: onContinue,
          ),
        ExerciseType.fillInTheBlank => FillInTheBlankExercise(
            exercise: exercise,
            onResult: onResult,
            onRetry: onRetry,
            onContinue: onContinue,
          ),
        ExerciseType.ordering => const _OrderingPlaceholder(),
      };
}

class _OrderingPlaceholder extends StatelessWidget {
  const _OrderingPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.06),
          borderRadius: const BorderRadius.all(AppRadius.large),
        ),
        child: Column(children: [
          const Icon(
            Icons.construction_rounded,
            color: AppColors.secondary,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ejercicio de ordenamiento — próximo sprint',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ]),
      );
}