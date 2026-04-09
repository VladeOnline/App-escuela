import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

// ─── Dropdown de materia ──────────────────────────────────────────────────────

class ExFormSubjectDropdown extends StatelessWidget {
  const ExFormSubjectDropdown({super.key, required this.value, required this.onChanged});
  final Subject value;
  final ValueChanged<Subject?> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: DropdownButtonFormField<Subject>(
        value: value,
        onChanged: onChanged,
        decoration: const InputDecoration(),
        items: Subject.values.map((s) => DropdownMenuItem(
          value: s,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.sm),
                Icon(s.icon, size: 16, color: s.color),
                const SizedBox(width: AppSpacing.xs),
                Text(s.label),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ─── Dropdown de tipo de ejercicio ────────────────────────────────────────────

class ExFormTypeDropdown extends StatelessWidget {
  const ExFormTypeDropdown({super.key, required this.value, required this.onChanged});
  final ExerciseType value;
  final ValueChanged<ExerciseType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: DropdownButtonFormField<ExerciseType>(
        value: value,
        onChanged: onChanged,
        decoration: const InputDecoration(),
        items: ExerciseType.values.map((t) => DropdownMenuItem(
          value: t,
          child: MouseRegion(cursor: SystemMouseCursors.click, child: Text(t.label)),
        )).toList(),
      ),
    );
  }
}

// ─── Dropdown de nivel de dificultad ─────────────────────────────────────────

class ExFormDifficultyDropdown extends StatelessWidget {
  const ExFormDifficultyDropdown({super.key, required this.value, required this.onChanged});
  final DifficultyLevel value;
  final ValueChanged<DifficultyLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: DropdownButtonFormField<DifficultyLevel>(
        value: value,
        onChanged: onChanged,
        decoration: const InputDecoration(),
        items: DifficultyLevel.values.map((d) => DropdownMenuItem(
          value: d,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.sm),
                Text(d.label),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ─── Badge de puntos por dificultad ──────────────────────────────────────────

class ExFormDifficultyBadge extends StatelessWidget {
  const ExFormDifficultyBadge({super.key, required this.level});
  final DifficultyLevel level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Este ejercicio otorgará ${level.basePoints} puntos al completarlo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
