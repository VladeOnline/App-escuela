import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class ModuleHeaderCard extends StatelessWidget {
  const ModuleHeaderCard({
    super.key,
    required this.module,
    required this.selectedSubject,
    required this.onSubjectChanged,
  });

  final ModuleEntity module;
  final Subject? selectedSubject;
  final ValueChanged<Subject?> onSubjectChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryLight.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleBlock(module: module),
                const SizedBox(height: AppSpacing.md),
                _SubjectFilter(
                  selected: selectedSubject,
                  onChanged: onSubjectChanged,
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _TitleBlock(module: module)),
              Container(
                width: 2,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              _SubjectFilter(
                selected: selectedSubject,
                onChanged: onSubjectChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Bloque del título ---

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.module});
  final ModuleEntity module;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(module.type.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                module.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Nunito',
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Nunito',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Filtro de materia (dropdown) ---

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({required this.selected, required this.onChanged});
  final Subject? selected;
  final ValueChanged<Subject?> onChanged;

  // Helper para no repetir MouseRegion en cada item
  DropdownMenuItem<T> _buildItem<T>({
    required T? value,
    required Widget child,
  }) {
    return DropdownMenuItem<T>(
      value: value,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            const Text(
              'Materia',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontFamily: 'Nunito',
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Subject?>(
              mouseCursor: SystemMouseCursors.click,
              value: selected,
              isDense: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Nunito',
              ),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              items: [
                _buildItem<Subject?>(
                  value: null,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.grid_view_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Todas'),
                    ],
                  ),
                ),
                ...Subject.values.map(
                  (s) => _buildItem<Subject?>(
                    value: s,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 16, color: s.color),
                        const SizedBox(width: 8),
                        Text(s.shortLabel),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

