import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_card.dart';

/// Sección de un nivel de dificultad. Renderiza un header coloreado + un grid
/// de ejercicios. El header tiene un "ojito" que activa el modo selección
/// masiva SOLO para esta sección.
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
    required this.onDeleteExercise,
  });

  final DifficultyLevel difficulty;
  final List<ExerciseEntity> exercises;
  final bool isTeacher;

  /// `true` si ESTA sección está actualmente en modo selección.
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final VoidCallback onToggleSelectionMode;
  final ValueChanged<ExerciseEntity> onTapExercise;
  final ValueChanged<ExerciseEntity> onDeleteExercise;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          difficulty: difficulty,
          count: exercises.length,
          isSelectionMode: isSelectionMode,
          isTeacher: isTeacher,
          onToggleSelectionMode: onToggleSelectionMode,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ExerciseGrid(
          exercises: exercises,
          isTeacher: isTeacher,
          isSelectionMode: isSelectionMode,
          selectedIds: selectedIds,
          onTapExercise: onTapExercise,
          onDeleteExercise: onDeleteExercise,
        ),
      ],
    );
  }
}

// ─── Header coloreado por nivel ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.difficulty,
    required this.count,
    required this.isSelectionMode,
    required this.isTeacher,
    required this.onToggleSelectionMode,
  });

  final DifficultyLevel difficulty;
  final int count;
  final bool isSelectionMode;
  final bool isTeacher;
  final VoidCallback onToggleSelectionMode;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(AppRadius.small),
            ),
            child: const Icon(Icons.layers_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Nivel ${difficulty.label}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _darken(color),
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.full),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _darken(color),
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const Spacer(),
          if (isTeacher)
            IconButton(
              onPressed: onToggleSelectionMode,
              tooltip: isSelectionMode
                  ? 'Salir del modo selección'
                  : 'Activar/desactivar masivamente',
              icon: Icon(
                isSelectionMode
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _darken(color),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.small),
                ),
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(32, 32),
              ),
            ),
        ],
      ),
    );
  }

  Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0, 1)).toColor();
  }
}

// ─── Grid responsive de ejercicios ───────────────────────────────────────────

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid({
    required this.exercises,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onTapExercise,
    required this.onDeleteExercise,
  });

  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final ValueChanged<ExerciseEntity> onTapExercise;
  final ValueChanged<ExerciseEntity> onDeleteExercise;

  @override
  Widget build(BuildContext context) {
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
            childAspectRatio: 0.78,
          ),
          itemCount: exercises.length,
          itemBuilder: (_, i) {
            final exercise = exercises[i];
            return ExerciseCard(
              exercise: exercise,
              isTeacher: isTeacher,
              isSelectionMode: isSelectionMode,
              isSelected: selectedIds.contains(exercise.id),
              onTap: () => onTapExercise(exercise),
              onDelete: () => onDeleteExercise(exercise),
            );
          },
        );
      },
    );
  }
}
