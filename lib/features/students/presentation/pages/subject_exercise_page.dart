import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../modules/data/repositories/api_module_repository.dart';
import '../../../modules/domain/entities/module_entities.dart';
import '../../../modules/presentation/pages/exercise_detail_page.dart';
import '../../../modules/presentation/widgets/module_detail/exercise_preview.dart';

class SubjectExercisePage extends StatefulWidget {
  const SubjectExercisePage({
    super.key,
    required this.subject,
    required this.level,
    required this.modules,
    required this.repository,
  });

  final Subject subject;
  final DifficultyLevel level;
  final List<ModuleEntity> modules;
  final ApiModuleRepository repository;

  @override
  State<SubjectExercisePage> createState() => _SubjectExercisePageState();
}

class _SubjectExercisePageState extends State<SubjectExercisePage> {
  List<ExerciseEntity> _allExercises = [];
  List<ExerciseEntity> _pendingExercises = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises({bool silent = false}) async {
    if (!mounted) return;
    if (silent) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final authState = context.read<AuthNotifier>().state;
      final studentId = authState.studentId ?? '';

      final allExercises = <ExerciseEntity>[];
      final pendingExercises = <ExerciseEntity>[];

      for (final module in widget.modules) {
        final allRes = await widget.repository.getExercisesByModule(
          module.id,
          studentId: studentId.isNotEmpty ? studentId : null,
        );
        final filtered = allRes.exercises
            .where((e) =>
                e.subject == widget.subject && e.difficulty == widget.level)
            .toList();
        allExercises.addAll(filtered);

        if (studentId.isNotEmpty) {
          final pendingRes = await widget.repository.getExercisesByModule(
            module.id,
            studentId: studentId,
            pendingOnly: true,
          );
          final filteredPending = pendingRes.exercises
              .where((e) =>
                  e.subject == widget.subject && e.difficulty == widget.level)
              .toList();
          pendingExercises.addAll(filteredPending);
        } else {
          pendingExercises.addAll(filtered);
        }
      }

      if (!mounted) return;
      setState(() {
        _allExercises = allExercises;
        _pendingExercises = pendingExercises;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar los ejercicios';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  int get _completedCount => _allExercises.length - _pendingExercises.length;
  int get _totalAttempts =>
      _allExercises.fold(0, (sum, e) => sum + e.studentAttempts);
  int get _correctAttempts =>
      _allExercises.fold(0, (sum, e) => sum + e.studentCorrectAttempts);
  int get _successCount => _totalAttempts > 0 ? _correctAttempts : _completedCount;
  int get _successTotal => _totalAttempts > 0 ? _totalAttempts : _allExercises.length;
  int get _failedCount => _successTotal - _successCount;
  double get _successRate => _successTotal == 0 ? 0 : _successCount / _successTotal;
  Set<String> get _pendingIds => _pendingExercises.map((e) => e.id).toSet();

  Future<void> _openExercise(ExerciseEntity exercise) async {
    final authState = context.read<AuthNotifier>().state;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailPage(
          exercise: exercise,
          repository: widget.repository,
          studentId: authState.studentId,
        ),
      ),
    );
    _loadExercises(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          _SubjectHeader(
            subject: widget.subject,
            level: widget.level,
            isRefreshing: _isRefreshing,
            onRefresh: () => _loadExercises(silent: true),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: widget.subject.color));
    }
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadExercises);
    }
    return _ExerciseContent(
      exercises: _allExercises,
      pendingIds: _pendingIds,
      successRate: _successRate,
      successCount: _successCount,
      successTotal: _successTotal,
      failedCount: _failedCount,
      completedCount: _completedCount,
      totalCount: _allExercises.length,
      subject: widget.subject,
      onExerciseTap: _openExercise,
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({
    required this.subject,
    required this.level,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final Subject subject;
  final DifficultyLevel level;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = subject.color;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.75)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
          child: Row(
            children: [
              Tooltip(
                message: 'Volver',
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(AppRadius.medium),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ejercicios de ${subject.label}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Nivel ${level.label}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Actualizar',
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(AppRadius.medium),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: isRefreshing ? null : onRefresh,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: isRefreshing
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contenido
// ---------------------------------------------------------------------------

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({
    required this.exercises,
    required this.pendingIds,
    required this.successRate,
    required this.successCount,
    required this.successTotal,
    required this.failedCount,
    required this.completedCount,
    required this.totalCount,
    required this.subject,
    required this.onExerciseTap,
  });

  final List<ExerciseEntity> exercises;
  final Set<String> pendingIds;
  final double successRate;
  final int successCount;
  final int successTotal;
  final int failedCount;
  final int completedCount;
  final int totalCount;
  final Subject subject;
  final Future<void> Function(ExerciseEntity) onExerciseTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de tasa — fondo blanco propio
          _SuccessRateBar(
            successRate: successRate,
            successCount: successCount,
            totalCount: successTotal,
            failedCount: failedCount,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Contenedor blanco con los ejercicios
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingIds.isEmpty && exercises.isNotEmpty)
                  _AllDoneMessage(subject: subject),

                if (exercises.isEmpty)
                  _EmptyState(subject: subject)
                else ...[
                  if (pendingIds.isNotEmpty) ...[
                    _SectionDivider(
                      title: 'Por hacer',
                      count: pendingIds.length,
                      color: subject.color,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ExerciseGrid(
                      exercises: exercises
                          .where((e) => pendingIds.contains(e.id))
                          .toList(),
                      pendingIds: pendingIds,
                      subject: subject,
                      onTap: onExerciseTap,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (completedCount > 0) ...[
                    _SectionDivider(
                      title: 'Completados',
                      count: completedCount,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ExerciseGrid(
                      exercises: exercises
                          .where((e) => !pendingIds.contains(e.id))
                          .toList(),
                      pendingIds: pendingIds,
                      subject: subject,
                      onTap: onExerciseTap,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de tasa de éxito
// ---------------------------------------------------------------------------

class _SuccessRateBar extends StatelessWidget {
  const _SuccessRateBar({
    required this.successRate,
    required this.successCount,
    required this.totalCount,
    required this.failedCount,
  });

  final double successRate;
  final int successCount;
  final int totalCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final failRate = 1 - successRate;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasa de éxito de este módulo',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: const BorderRadius.all(AppRadius.full),
            child: SizedBox(
              height: 12,
              child: totalCount == 0
                  ? Container(color: AppColors.border)
                  : Row(
                      children: [
                        if (successRate > 0)
                          Expanded(
                            flex: (successRate * 100).round(),
                            child: Container(color: AppColors.success),
                          ),
                        if (failRate > 0)
                          Expanded(
                            flex: (failRate * 100).round(),
                            child: Container(color: AppColors.error),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(successRate * 100).toStringAsFixed(0)}% ($successCount)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ]),
              const Spacer(),
              Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(failRate * 100).toStringAsFixed(0)}% ($failedCount)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Divisor de sección
// ---------------------------------------------------------------------------

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.layers_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.4),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.all(AppRadius.full),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grid de ejercicios
// ---------------------------------------------------------------------------

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid({
    required this.exercises,
    required this.pendingIds,
    required this.subject,
    required this.onTap,
  });

  final List<ExerciseEntity> exercises;
  final Set<String> pendingIds;
  final Subject subject;
  final Future<void> Function(ExerciseEntity) onTap;

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
          runSpacing: AppSpacing.md,
          children: [
            for (final exercise in exercises)
              SizedBox(
                width: cardWidth,
                height: 220,
                child: _StudentExerciseCard(
                  exercise: exercise,
                  isPending: pendingIds.contains(exercise.id),
                  onTap: pendingIds.contains(exercise.id)
                      ? () => onTap(exercise)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card de ejercicio
// ---------------------------------------------------------------------------

class _StudentExerciseCard extends StatelessWidget {
  const _StudentExerciseCard({
    required this.exercise,
    required this.isPending,
    required this.onTap,
  });

  final ExerciseEntity exercise;
  final bool isPending;
  final VoidCallback? onTap;

  static IconData _typeIcon(ExerciseType type) => switch (type) {
        ExerciseType.multipleChoice => Icons.radio_button_checked_rounded,
        ExerciseType.trueOrFalse => Icons.check_circle_outline_rounded,
        ExerciseType.fillInTheBlank => Icons.text_fields_rounded,
        ExerciseType.ordering => Icons.sort_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final diffColor = exercise.difficulty.color;

    return Opacity(
      opacity: isPending ? 1.0 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.large),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.large),
          child: InkWell(
            onTap: onTap,
            mouseCursor: isPending
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            borderRadius: const BorderRadius.all(AppRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.1),
                          borderRadius:
                              const BorderRadius.all(AppRadius.small),
                        ),
                        child: Icon(_typeIcon(exercise.type),
                            size: 16, color: diffColor),
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
                          ),
                        ),
                      ),
                      if (!isPending)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 18),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Preview
                  Expanded(
                      child: ExercisePreviewWidget(exercise: exercise)),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    child: Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.6)),
                  ),

                  // Tag materia
                  _SubjectTag(subject: exercise.subject),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    child: Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.6)),
                  ),

                  // Footer
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PointsBadge(points: exercise.points),
                    ],
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
            ),
          ),
        ],
      ),
    );
  }
}

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
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.star_rounded,
              size: 13, color: AppColors.secondary),
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

// ---------------------------------------------------------------------------
// Mensaje todo completado
// ---------------------------------------------------------------------------

class _AllDoneMessage extends StatelessWidget {
  const _AllDoneMessage({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded,
                color: AppColors.success, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Todo completado! 🎉',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No tienes ejercicios pendientes en ${subject.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: subject.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(subject.icon,
                  size: 40, color: subject.color.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin ejercicios de ${subject.label}',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tu profesor aún no ha asignado ejercicios aquí',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
