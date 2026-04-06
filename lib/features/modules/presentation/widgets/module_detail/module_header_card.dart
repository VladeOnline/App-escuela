import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

/// Header del módulo: título, ícono, descripción corta y filtro por materia.
class ModuleHeaderCard extends StatelessWidget {
  const ModuleHeaderCard({
    super.key,
    required this.module,
    required this.selectedSubject,
    required this.onSubjectChanged,
  });

  final ModuleEntity module;

  /// `null` significa "todas las materias".
  final Subject? selectedSubject;
  final ValueChanged<Subject?> onSubjectChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.success.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
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
                width: 1,
                height: 56,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

// ─── Bloque del título ───────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.module});
  final ModuleEntity module;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Icon(module.type.icon, color: AppColors.success, size: 24),
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
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                module.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Nunito',
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Filtro de materia (dropdown) ────────────────────────────────────────────

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({required this.selected, required this.onChanged});
  final Subject? selected;
  final ValueChanged<Subject?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Materia',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
            fontFamily: 'Nunito',
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Subject?>(
              value: selected,
              isDense: true,
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Nunito',
              ),
              items: [
                const DropdownMenuItem<Subject?>(
                  value: null,
                  child: Text('Todas'),
                ),
                ...Subject.values.map(
                  (s) => DropdownMenuItem<Subject?>(
                    value: s,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 14, color: s.color),
                        const SizedBox(width: 6),
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
