import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../modules/data/repositories/api_module_repository.dart';
import '../../../../modules/domain/entities/module_entities.dart';
import '../../pages/exercise_level_page.dart' show SubjectStats;
import '../../pages/subject_exercise_page.dart';

class LevelSection extends StatefulWidget {
  const LevelSection({
    super.key,
    required this.level,
    required this.subjectStats,
    required this.moduleType,
    required this.repository,
    required this.onModuleTap,
  });

  final DifficultyLevel level;
  final Map<Subject, SubjectStats> subjectStats;
  final ModuleType moduleType;
  final ApiModuleRepository repository;
  final Future<void> Function(ModuleEntity) onModuleTap;

  @override
  State<LevelSection> createState() => _LevelSectionState();
}

class _LevelSectionState extends State<LevelSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;

  void _toggle() => setState(() => _expanded = !_expanded);

  double get _levelProgress {
    if (widget.subjectStats.isEmpty) return 0;
    final totalEx =
        widget.subjectStats.values.fold(0, (s, e) => s + e.totalExercises);
    final completedEx = widget.subjectStats.values
        .fold(0, (s, e) => s + e.completedExercises);
    return totalEx == 0 ? 0 : completedEx / totalEx;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LevelHeader(
          level: widget.level,
          progress: _levelProgress,
          expanded: _expanded,
          onTap: _toggle,
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          clipBehavior: Clip.none,
          child: _expanded
              ? (widget.subjectStats.isEmpty
                  ? _LevelEmptyState(level: widget.level)
                  : _SubjectGrid(
                      subjectStats: widget.subjectStats,
                      level: widget.level,
                      repository: widget.repository,
                    ))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.level,
    required this.progress,
    required this.expanded,
    required this.onTap,
  });

  final DifficultyLevel level;
  final double progress;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: level.color.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.all(AppRadius.medium),
            border: Border.all(color: level.color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: level.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Nivel ${level.label}',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: level.color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: level.color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.expand_more_rounded,
                        color: level.color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: const BorderRadius.all(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: level.color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(level.color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelEmptyState extends StatelessWidget {
  const _LevelEmptyState({required this.level});
  final DifficultyLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: level.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 20, color: level.color.withValues(alpha: 0.4)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sin actividades de nivel ${level.label} por ahora',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: level.color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({
    required this.subjectStats,
    required this.level,
    required this.repository,
  });

  final Map<Subject, SubjectStats> subjectStats;
  final DifficultyLevel level;
  final ApiModuleRepository repository;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 700 ? 3 : 2;
        const spacing = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - spacing * (crossCount - 1)) / crossCount;

        return Wrap(
          spacing: spacing,
          runSpacing: AppSpacing.lg,
          clipBehavior: Clip.none,
          children: [
            for (final entry in subjectStats.entries)
              SizedBox(
                width: cardWidth,
                child: _SubjectCard(
                  stats: entry.value,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubjectExercisePage(
                        subject: entry.value.subject,
                        level: level,
                        modules: entry.value.modules,
                        repository: repository,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SubjectCard extends StatefulWidget {
  const _SubjectCard({required this.stats, required this.onTap});

  final SubjectStats stats;
  final VoidCallback onTap;

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.03).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.stats.subject;
    final color = subject.color;
    final progress = widget.stats.progressRate;
    final pending = widget.stats.pendingExercises;
    final total = widget.stats.totalExercises;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.large),
              border: Border.all(
                color: _hovered
                    ? color.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.2),
                width: _hovered ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? color.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: _hovered ? 20 : 8,
                  spreadRadius: _hovered ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.7)],
                        ),
                        borderRadius: const BorderRadius.all(AppRadius.medium),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(subject.icon, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    if (pending > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: const BorderRadius.all(AppRadius.full),
                          border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 10, color: AppColors.warning),
                            const SizedBox(width: 3),
                            Text(
                              '$pending pendiente${pending != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.all(AppRadius.full),
                        ),
                        child: const Text(
                          '¡Al día! ✓',
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subject.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total ejercicio${total != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% completado',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 11, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}