import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_preview.dart';

/// Card de un ejercicio con preview, etiqueta de materia, título y puntos.
///
/// Soporta dos modos:
/// - Normal: tap → abrir detalle. Menú de 3 puntitos para eliminar.
/// - Selección masiva: tap → toggle. Muestra checkbox animado.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final ExerciseEntity exercise;
  final bool isTeacher;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isInactive = !exercise.isActive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: isSelectionMode && isSelected
              ? AppColors.primary
              : AppColors.border,
          width: isSelectionMode && isSelected ? 2 : 1,
        ),
        color: AppColors.surfaceCard,
        boxShadow: isSelectionMode && isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Opacity(
        opacity: isInactive ? 0.55 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(AppRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CardHeader(
                    exercise: exercise,
                    isTeacher: isTeacher,
                    isSelectionMode: isSelectionMode,
                    isSelected: isSelected,
                    onDelete: onDelete,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExercisePreviewWidget(exercise: exercise),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  _SubjectTag(subject: exercise.subject),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  _CardFooter(
                    title: exercise.title,
                    points: exercise.points,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header de la card (icono + tipo + acciones) ─────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.exercise,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onDelete,
  });

  final ExerciseEntity exercise;
  final bool isTeacher;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _typeIcon(exercise.type),
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            exercise.type.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        if (isSelectionMode)
          _AnimatedCheckbox(isSelected: isSelected)
        else if (isTeacher)
          _DeleteMenu(
            onDelete: onDelete,
            exerciseTitle: exercise.title,
          ),
      ],
    );
  }

  IconData _typeIcon(ExerciseType type) => switch (type) {
        ExerciseType.multipleChoice => Icons.radio_button_checked_rounded,
        ExerciseType.trueOrFalse => Icons.check_circle_outline_rounded,
        ExerciseType.fillInTheBlank => Icons.text_fields_rounded,
        ExerciseType.ordering => Icons.sort_rounded,
      };
}

// ─── Footer (título + puntos) ────────────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.title, required this.points});
  final String title;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 13, color: AppColors.secondary),
              const SizedBox(width: 2),
              Text(
                '$points pts',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Etiqueta de materia ─────────────────────────────────────────────────────

class _SubjectTag extends StatelessWidget {
  const _SubjectTag({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: subject.color.withOpacity(0.12),
          borderRadius: const BorderRadius.all(AppRadius.full),
          border: Border.all(color: subject.color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(subject.icon, size: 11, color: subject.color),
            const SizedBox(width: 4),
            Text(
              subject.shortLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: subject.color,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Checkbox animado para modo selección ────────────────────────────────────

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.small),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isSelected
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ─── Menú de 3 puntitos ──────────────────────────────────────────────────────

class _DeleteMenu extends StatelessWidget {
  const _DeleteMenu({required this.onDelete, required this.exerciseTitle});
  final VoidCallback onDelete;
  final String exerciseTitle;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textHint),
      tooltip: 'Más opciones',
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Eliminar ejercicio'),
            ],
          ),
        ),
      ],
      onSelected: (_) => onDelete(),
    );
  }
}
