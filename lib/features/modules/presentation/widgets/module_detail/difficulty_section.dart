import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_card.dart';

class DifficultySection extends StatelessWidget {
  const DifficultySection({
    super.key,
    required this.difficulty,
    required this.exercises,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelectionMode,
    required this.onTapExercise,
    this.onEditExercise,
    required this.onDeleteExercise,
    this.onCreateExercise,
  });

  final DifficultyLevel difficulty;
  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final VoidCallback onToggleSelectionMode;
  final ValueChanged<ExerciseEntity> onTapExercise;
  final ValueChanged<ExerciseEntity>? onEditExercise;
  final ValueChanged<ExerciseEntity> onDeleteExercise;
  final VoidCallback? onCreateExercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          difficulty: difficulty,
          isSelectionMode: isSelectionMode,
          isTeacher: isTeacher,
          onToggleSelectionMode: exercises.isEmpty ? () {} : onToggleSelectionMode,
          isEmpty: exercises.isEmpty,
        ),
        const SizedBox(height: AppSpacing.md),
        if (exercises.isEmpty)
          _EmptyLevelMessage(
            difficulty: difficulty,
            onCreateExercise: isTeacher ? onCreateExercise : null,
          )
        else
          _ExerciseGrid(
            exercises: exercises,
            isTeacher: isTeacher,
            isSelectionMode: isSelectionMode,
            selectedIds: selectedIds,
            onTapExercise: onTapExercise,
            onEditExercise: onEditExercise,
            onDeleteExercise: onDeleteExercise,
            difficulty: difficulty,
            onCreateExercise: onCreateExercise,
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.difficulty,
    required this.isSelectionMode,
    required this.isTeacher,
    required this.onToggleSelectionMode,
    required this.isEmpty,
  });

  final DifficultyLevel difficulty;
  final bool isSelectionMode;
  final bool isTeacher;
  final VoidCallback onToggleSelectionMode;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.color;

    return Row(
      children: [
        // ── Ícono de nivel ───
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.small),
          ),
          child: _SignalIcon(difficulty: difficulty, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── Texto del nivel ───
        Text(
          'Nivel ${difficulty.label}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'Nunito',
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── Línea degradada ───
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.55), color.withOpacity(0.0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // ── Ojito ───
        if (isTeacher)
          Tooltip(
            message: isSelectionMode ? 'Salir de selección' : 'Activar / Desactivar',
            child: MouseRegion(
              cursor: isEmpty ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: isEmpty ? null : onToggleSelectionMode,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelectionMode
                        ? color.withOpacity(0.15)
                        : color.withOpacity(0.12),
                    borderRadius: const BorderRadius.all(AppRadius.small),
                  ),
                  child: Icon(
                    isSelectionMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 16,
                    color: isEmpty ? color.withOpacity(0.3) : color,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Mensaje cuando no hay ejercicios ───

class _EmptyLevelMessage extends StatelessWidget {
  const _EmptyLevelMessage({
    required this.difficulty,
    this.onCreateExercise,
  });

  final DifficultyLevel difficulty;
  final VoidCallback? onCreateExercise;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: const BorderRadius.all(AppRadius.small),
            ),
            child: Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── Texto + acción ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No hay ejercicios para este nivel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                if (onCreateExercise != null)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onCreateExercise,
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          children: [
                            const TextSpan(text: '¿Empezamos? '),
                            TextSpan(
                              text: 'Crea el primer ejercicio ${difficulty.label.toLowerCase()}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                                decoration: TextDecoration.underline,
                                decorationColor: color,
                              ),
                            ),
                            const TextSpan(text: ' →'),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'El docente aún no ha agregado ejercicios ${difficulty.label.toLowerCase()}.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ícono de señal con barras activas/inactivas ───

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.difficulty, required this.color});

  final DifficultyLevel difficulty;
  final Color color;

  static const IconData _base = Icons.signal_cellular_alt_rounded;

  IconData get _activeIcon => switch (difficulty) {
        DifficultyLevel.basic        => Icons.signal_cellular_alt_1_bar_rounded,
        DifficultyLevel.intermediate => Icons.signal_cellular_alt_2_bar_rounded,
        DifficultyLevel.advanced     => Icons.signal_cellular_alt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        children: [
          Icon(_base, size: 16, color: color.withOpacity(0.25)),
          Icon(_activeIcon, size: 16, color: color),
        ],
      ),
    );
  }
}

// ─── Grid responsive de ejercicios ───

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid({
    required this.exercises,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onTapExercise,
    this.onEditExercise,
    required this.onDeleteExercise,
    required this.difficulty,
    this.onCreateExercise,
  });

  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final ValueChanged<ExerciseEntity> onTapExercise;
  final ValueChanged<ExerciseEntity>? onEditExercise;
  final ValueChanged<ExerciseEntity> onDeleteExercise;
  final DifficultyLevel difficulty;
  final VoidCallback? onCreateExercise;

  @override
  Widget build(BuildContext context) {
    final showAddCard = isTeacher && !isSelectionMode && onCreateExercise != null;
    final itemCount = exercises.length + (showAddCard ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 720
            ? 3
            : constraints.maxWidth > 460
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
          ),
          itemCount: itemCount,
          itemBuilder: (_, i) {
            if (showAddCard && i == exercises.length) {
              return AddExerciseCard(
                difficulty: difficulty,
                onTap: onCreateExercise!,
              );
            }
            final exercise = exercises[i];
            return ExerciseCard(
              exercise: exercise,
              isTeacher: isTeacher,
              isSelectionMode: isSelectionMode,
              isSelected: selectedIds.contains(exercise.id),
              onTap: () => onTapExercise(exercise),
              onEdit: onEditExercise != null ? () => onEditExercise!(exercise) : null,
              onDelete: () => onDeleteExercise(exercise),
            );
          },
        );
      },
    );
  }
}