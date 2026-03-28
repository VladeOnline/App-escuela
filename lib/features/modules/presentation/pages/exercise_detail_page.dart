import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercises/multiple_choice_exercise.dart';
import '../widgets/exercises/other_exercises.dart';

/// Página de un ejercicio individual.
///
/// Muestra instrucciones, el widget del ejercicio correspondiente,
/// y el resultado con puntos al terminar (RF-24, RF-20, RF-35).
class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key, required this.exercise});

  final ExerciseEntity exercise;

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  ExerciseResult? _result;

  void _onResult(ExerciseResult result) {
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.exercise.title),
        actions: [
          // Badge de dificultad
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _DifficultyBadge(level: widget.exercise.difficulty),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucciones
                _InstructionsCard(
                    instructions: widget.exercise.instructions),
                const SizedBox(height: AppSpacing.lg),

                // Widget de ejercicio según tipo
                _buildExerciseWidget(),

                // Resultado al finalizar
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _ResultCard(result: _result!),
                  const SizedBox(height: AppSpacing.lg),
                  // Botón para volver (RF-35: el alumno puede repetirlo)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Volver a los ejercicios'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseWidget() {
    return switch (widget.exercise.type) {
      ExerciseType.multipleChoice => MultipleChoiceExercise(
          exercise: widget.exercise,
          onResult: _onResult,
        ),
      ExerciseType.trueOrFalse => TrueOrFalseExercise(
          exercise: widget.exercise,
          onResult: _onResult,
        ),
      ExerciseType.fillInTheBlank => FillInTheBlankExercise(
          exercise: widget.exercise,
          onResult: _onResult,
        ),
      ExerciseType.ordering => _OrderingPlaceholder(),
    };
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.instructions});
  final String instructions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.06),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instrucciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructions,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.level});
  final DifficultyLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: level.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt_rounded,
              color: level.color, size: 14),
          const SizedBox(width: 4),
          Text(
            level.label,
            style: TextStyle(
              color: level.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final ExerciseResult result;

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect
                ? Icons.celebration_rounded
                : Icons.sentiment_dissatisfied_rounded,
            color: color,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isCorrect ? '¡Excelente trabajo!' : '¡Sigue intentando!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isCorrect
                ? 'Respondiste correctamente.'
                : 'No te preocupes, puedes volver e intentarlo de nuevo.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (isCorrect) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: const BorderRadius.all(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded,
                      color: AppColors.secondary, size: 22),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+${result.pointsEarned} puntos',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.06),
        borderRadius: const BorderRadius.all(AppRadius.large),
      ),
      child: Column(
        children: [
          const Icon(Icons.construction_rounded,
              color: AppColors.secondary, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ejercicio de ordenamiento — próximo sprint',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
