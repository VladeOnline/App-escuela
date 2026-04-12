import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_preview.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
    required this.onDelete,
  });

  final ExerciseEntity exercise;
  final bool isTeacher;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: isSelectionMode && isSelected ? AppColors.primary : AppColors.border,
          width: isSelectionMode && isSelected ? 2.5 : 1,
        ),
        color: Colors.white,
        boxShadow: isSelectionMode && isSelected
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Opacity(
        opacity: exercise.isActive ? 1 : 0.5,
        child: Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.large),
          child: InkWell(
            onTap: onTap,
            mouseCursor: SystemMouseCursors.click,
            borderRadius: const BorderRadius.all(AppRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    exercise: exercise,
                    isTeacher: isTeacher,
                    isSelectionMode: isSelectionMode,
                    isSelected: isSelected,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(child: ExercisePreviewWidget(exercise: exercise)),
                  _divider(),
                  _SubjectTag(subject: exercise.subject),
                  _divider(),
                  _CardFooter(title: exercise.title, points: exercise.points),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Divider(height: 1, thickness: 1, color: AppColors.border.withValues(alpha: 0.6)),
      );
}

// --- Header ---

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.exercise,
    required this.isTeacher,
    required this.isSelectionMode,
    required this.isSelected,
    this.onEdit,
    required this.onDelete,
  });

  final ExerciseEntity exercise;
  final bool isTeacher;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  static IconData _typeIcon(ExerciseType type) => switch (type) {
        ExerciseType.multipleChoice => Icons.radio_button_checked_rounded,
        ExerciseType.trueOrFalse    => Icons.check_circle_outline_rounded,
        ExerciseType.fillInTheBlank => Icons.text_fields_rounded,
        ExerciseType.ordering       => Icons.sort_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: exercise.difficulty.color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.all(AppRadius.small),
          ),
          child: Icon(_typeIcon(exercise.type), size: 16, color: exercise.difficulty.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            exercise.type.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: 'Nunito',
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (isSelectionMode)
          _AnimatedCheckbox(isSelected: isSelected)
        else if (isTeacher)
          _ActionsMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }
}

// --- Footer ---

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
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _PointsBadge(points: points),
      ],
    );
  }
}

// --- Badge de puntos ---

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.star_rounded, size: 13, color: AppColors.secondary),
        ),
        const SizedBox(width: 5),
        Text(
          '$points pts',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}

// --- Etiqueta de materia ---

class _SubjectTag extends StatelessWidget {
  const _SubjectTag({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subject.color.withValues(alpha: 0.10),
        borderRadius: const BorderRadius.all(AppRadius.small),
        border: Border.all(color: subject.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(subject.icon, size: 12, color: subject.color),
          const SizedBox(width: 6),
          Text(
            subject.shortLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: subject.color,
              fontFamily: 'Nunito',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Checkbox animado ---

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.small),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
            : [],
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

// --- Menú de acciones ---

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({this.onEdit, required this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textHint),
      tooltip: 'Más opciones',
      style: const ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.large),
        side: BorderSide(color: AppColors.border),
      ),
      elevation: 4,
      itemBuilder: (_) => [
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            mouseCursor: SystemMouseCursors.click,
            child: const Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Editar', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          mouseCursor: SystemMouseCursors.click,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 12),
              Text('Eliminar', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete();
      },
    );
  }
}

// --- Card para agregar ejercicio ---

class AddExerciseCard extends StatefulWidget {
  const AddExerciseCard({
    super.key,
    required this.difficulty,
    required this.onTap,
  });

  final DifficultyLevel difficulty;
  final VoidCallback onTap;

  @override
  State<AddExerciseCard> createState() => _AddExerciseCardState();
}

class _AddExerciseCardState extends State<AddExerciseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.difficulty.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: color.withValues(alpha: _hovered ? 0.12 : 0.05),
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(
              color: color.withValues(alpha: _hovered ? 0.5 : 0.25),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _hovered ? 0.25 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 28, color: color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Agregar ejercicio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.difficulty.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.6),
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

