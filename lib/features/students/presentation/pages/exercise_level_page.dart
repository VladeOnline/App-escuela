import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../modules/data/repositories/api_module_repository.dart';
import '../../../modules/domain/entities/module_entities.dart';
import '../../../modules/presentation/pages/module_detail_page.dart';
import '../widgets/exercise_level/level_section.dart';
import '../widgets/exercise_level/subject_stat_cards.dart';

class ExerciseLevelPage extends StatefulWidget {
  const ExerciseLevelPage({
    super.key,
    required this.moduleType,
    required this.repository,
  });

  final ModuleType moduleType;
  final ApiModuleRepository repository;

  @override
  State<ExerciseLevelPage> createState() => _ExerciseLevelPageState();
}

class _ExerciseLevelPageState extends State<ExerciseLevelPage> {
  List<ModuleEntity> _modules = [];
  Map<String, List<ExerciseEntity>> _exercisesMap = {};
  Map<String, List<ExerciseEntity>> _pendingMap = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool get _isMathCard => widget.moduleType == ModuleType.math;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthNotifier>().state;
      final grade = authState.studentGrade ?? 1;
      final studentId = authState.studentId ?? '';

      late List<ModuleEntity> gradeModules;
      if (_isMathCard) {
        final readingRes =
            await widget.repository.getModulesByType(ModuleType.reading);
        final writingRes =
            await widget.repository.getModulesByType(ModuleType.writing);
        final mathRes = await widget.repository.getModulesByType(ModuleType.math);

        final firstFailure =
            readingRes.failure ?? writingRes.failure ?? mathRes.failure;
        if (firstFailure != null) {
          setState(() {
            _errorMessage = firstFailure.message;
            _isLoading = false;
          });
          return;
        }

        final byId = <String, ModuleEntity>{};
        for (final module in [
          ...readingRes.modules,
          ...writingRes.modules,
          ...mathRes.modules,
        ]) {
          if (module.grade == grade) {
            byId[module.id] = module;
          }
        }
        gradeModules = byId.values.toList();
      } else {
        final result =
            await widget.repository.getModulesByType(widget.moduleType);
        if (result.failure != null) {
          setState(() {
            _errorMessage = result.failure!.message;
            _isLoading = false;
          });
          return;
        }
        gradeModules = result.modules.where((m) => m.grade == grade).toList();
      }

      final exercisesMap = <String, List<ExerciseEntity>>{};
      final pendingMap = <String, List<ExerciseEntity>>{};

      for (final module in gradeModules) {
        final allRes = await widget.repository.getExercisesByModule(
          module.id,
          studentId: studentId.isNotEmpty ? studentId : null,
        );
        final allExercises = _isMathCard
            ? allRes.exercises
                .where((exercise) => exercise.subject == Subject.math)
                .toList()
            : allRes.exercises
                .where((exercise) => exercise.subject != Subject.math)
                .toList();
        exercisesMap[module.id] = allExercises;

        if (studentId.isNotEmpty) {
          final pendingRes = await widget.repository.getExercisesByModule(
            module.id,
            studentId: studentId,
            pendingOnly: true,
          );
          pendingMap[module.id] = _isMathCard
              ? pendingRes.exercises
                  .where((exercise) => exercise.subject == Subject.math)
                  .toList()
              : pendingRes.exercises
                  .where((exercise) => exercise.subject != Subject.math)
                  .toList();
        } else {
          pendingMap[module.id] = allExercises;
        }
      }

      if (_isMathCard) {
        gradeModules = gradeModules
            .where((module) => (exercisesMap[module.id] ?? const []).isNotEmpty)
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _modules = gradeModules;
        _exercisesMap = exercisesMap;
        _pendingMap = pendingMap;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar los módulos';
        _isLoading = false;
      });
    }
  }

  int get _totalExercises =>
      _exercisesMap.values.fold(0, (s, e) => s + e.length);
  int get _pendingExercises =>
      _pendingMap.values.fold(0, (s, e) => s + e.length);
  int get _completedExercises => _totalExercises - _pendingExercises;
  int get _totalAttempts =>
      _exercisesMap.values.expand((e) => e).fold(0, (s, e) => s + e.studentAttempts);
  int get _correctAttempts =>
      _exercisesMap.values
          .expand((e) => e)
          .fold(0, (s, e) => s + e.studentCorrectAttempts);
  int get _successCount => _totalAttempts > 0 ? _correctAttempts : _completedExercises;
  int get _successTotal => _totalAttempts > 0 ? _totalAttempts : _totalExercises;
  double get _successRate =>
      _successTotal == 0 ? 0 : _successCount / _successTotal;

  Map<DifficultyLevel, Map<Subject, SubjectStats>> get _grouped {
    if (_modules.isEmpty) return {};

    final result = <DifficultyLevel, Map<Subject, SubjectStats>>{};

    for (final module in _modules) {
      final allEx = _exercisesMap[module.id] ?? [];
      final pendEx = _pendingMap[module.id] ?? [];

      for (final exercise in allEx) {
        final level = exercise.difficulty;
        final subject = exercise.subject;
        final isPending = pendEx.any((p) => p.id == exercise.id);

        result[level] ??= {};
        final subjectMap = result[level]!;
        final existing = subjectMap[subject];

        subjectMap[subject] = SubjectStats(
          subject: subject,
          modules: existing == null
              ? [module]
              : existing.modules.contains(module)
                  ? existing.modules
                  : [...existing.modules, module],
          totalExercises: (existing?.totalExercises ?? 0) + 1,
          pendingExercises:
              (existing?.pendingExercises ?? 0) + (isPending ? 1 : 0),
        );
      }

      if (allEx.isEmpty && !_isMathCard) {
        result[DifficultyLevel.basic] ??= {};
        final subjectMap = result[DifficultyLevel.basic]!;
        final existing = subjectMap[Subject.spanish];
        subjectMap[Subject.spanish] = SubjectStats(
          subject: Subject.spanish,
          modules: existing == null
              ? [module]
              : existing.modules.contains(module)
                  ? existing.modules
                  : [...existing.modules, module],
          totalExercises: existing?.totalExercises ?? 0,
          pendingExercises: existing?.pendingExercises ?? 0,
        );
      }
    }

    return result;
  }

  void _showReport(BuildContext context) {
    final name =
        context.read<AuthNotifier>().state.userName ?? 'Estudiante';
    showDialog<void>(
      context: context,
      builder: (_) => _StudentReportDialog(
        studentName: name,
        moduleType: widget.moduleType,
        totalExercises: _totalExercises,
        completedExercises: _completedExercises,
        pendingExercises: _pendingExercises,
        successRate: _successRate,
        grouped: _grouped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          _ExerciseLevelHeader(
            moduleType: widget.moduleType,
            onInfoTap: _isLoading ? null : () => _showReport(context),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadData);
    }
    if (_modules.isEmpty) {
      return _EmptyState(moduleType: widget.moduleType);
    }
    return _ExerciseLevelContent(
      moduleType: widget.moduleType,
      grouped: _grouped,
      totalExercises: _totalExercises,
      completedExercises: _completedExercises,
      pendingExercises: _pendingExercises,
      successCount: _successCount,
      successTotal: _successTotal,
      successRate: _successRate,
      repository: widget.repository,
      onModuleTap: _onModuleTap,
      onDataRefresh: _loadData,
    );
  }

  Future<void> _onModuleTap(ModuleEntity module) async {
    final authState = context.read<AuthNotifier>().state;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModuleDetailPage(
          module: module,
          repository: widget.repository,
          isTeacher: false,
          studentId: authState.studentId,
        ),
      ),
    );
    _loadData();
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ExerciseLevelHeader extends StatelessWidget {
  const _ExerciseLevelHeader({
    required this.moduleType,
    required this.onInfoTap,
  });

  final ModuleType moduleType;
  final VoidCallback? onInfoTap;

  static const _gradients = {
    ModuleType.reading: [Color(0xFF0D9488), Color(0xFF14B8A6)],
    ModuleType.writing: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ModuleType.math: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradients[moduleType]!,
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
              Icon(moduleType.icon, color: Colors.white, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(
                moduleType.label,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Ver reporte del estudiante',
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(AppRadius.medium),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: onInfoTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(AppRadius.medium),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
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

class _ExerciseLevelContent extends StatelessWidget {
  const _ExerciseLevelContent({
    required this.moduleType,
    required this.grouped,
    required this.totalExercises,
    required this.completedExercises,
    required this.pendingExercises,
    required this.successCount,
    required this.successTotal,
    required this.successRate,
    required this.repository,
    required this.onModuleTap,
    required this.onDataRefresh,
  });

  final ModuleType moduleType;
  final Map<DifficultyLevel, Map<Subject, SubjectStats>> grouped;
  final int totalExercises;
  final int completedExercises;
  final int pendingExercises;
  final int successCount;
  final int successTotal;
  final double successRate;
  final ApiModuleRepository repository;
  final Future<void> Function(ModuleEntity) onModuleTap;
  final Future<void> Function() onDataRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectStatCards(
              totalExercises: totalExercises,
              completedExercises: completedExercises,
              pendingExercises: pendingExercises,
              successCount: successCount,
              successTotal: successTotal,
              successRate: successRate,
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final level in DifficultyLevel.values) ...[
              LevelSection(
                level: level,
                subjectStats: grouped[level] ?? {},
                moduleType: moduleType,
                repository: repository,
                onModuleTap: onModuleTap,
                onDataRefresh: onDataRefresh,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog reporte
// ---------------------------------------------------------------------------

class _StudentReportDialog extends StatelessWidget {
  const _StudentReportDialog({
    required this.studentName,
    required this.moduleType,
    required this.totalExercises,
    required this.completedExercises,
    required this.pendingExercises,
    required this.successRate,
    required this.grouped,
  });

  final String studentName;
  final ModuleType moduleType;
  final int totalExercises;
  final int completedExercises;
  final int pendingExercises;
  final double successRate;
  final Map<DifficultyLevel, Map<Subject, SubjectStats>> grouped;

  static const _moduleColors = {
    ModuleType.reading: Color(0xFF0D9488),
    ModuleType.writing: Color(0xFF8B5CF6),
    ModuleType.math: Color(0xFFF59E0B),
  };

  Color _rateColor(double r) {
    if (r >= 0.7) return AppColors.success;
    if (r >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  Map<Subject, ({int total, int pending})> get _bySubject {
    final map = <Subject, ({int total, int pending})>{};
    for (final levelMap in grouped.values) {
      for (final entry in levelMap.entries) {
        final ex = map[entry.key];
        map[entry.key] = (
          total: (ex?.total ?? 0) + entry.value.totalExercises,
          pending: (ex?.pending ?? 0) + entry.value.pendingExercises,
        );
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final color = _moduleColors[moduleType]!;
    final subjects = _bySubject;

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.all(AppRadius.medium),
                  ),
                  child:
                      Icon(Icons.assessment_rounded, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reporte de',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Nunito',
                              color: AppColors.textSecondary)),
                      Text(studentName,
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: color)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatChip(
                  label: 'Completados',
                  value: '$completedExercises/$totalExercises',
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Tasa de éxito',
                  value: '${(successRate * 100).toStringAsFixed(0)}%',
                  color: _rateColor(successRate),
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Pendientes',
                  value: '$pendingExercises',
                  color: pendingExercises == 0
                      ? AppColors.success
                      : AppColors.warning,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (subjects.isNotEmpty) ...[
              const Text('Por materia',
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in subjects.entries) ...[
                _SubjectReportRow(
                  subject: entry.key,
                  total: entry.value.total,
                  pending: entry.value.pending,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.all(AppRadius.medium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SubjectReportRow extends StatelessWidget {
  const _SubjectReportRow(
      {required this.subject, required this.total, required this.pending});

  final Subject subject;
  final int total;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final completed = total - pending;
    final progress = total == 0 ? 0.0 : completed / total;
    final color = subject.color;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(AppRadius.small),
            ),
            child: Icon(subject.icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.moduleType});
  final ModuleType moduleType;

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
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(moduleType.icon,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Sin módulos de ${moduleType.label}',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Tu profesor aún no ha asignado actividades',
                style: Theme.of(context).textTheme.bodyMedium),
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

// ---------------------------------------------------------------------------
// Modelo exportado
// ---------------------------------------------------------------------------

class SubjectStats {
  final Subject subject;
  final List<ModuleEntity> modules;
  final int totalExercises;
  final int pendingExercises;

  const SubjectStats({
    required this.subject,
    required this.modules,
    required this.totalExercises,
    required this.pendingExercises,
  });

  int get completedExercises => totalExercises - pendingExercises;
  double get progressRate =>
      totalExercises == 0 ? 0 : completedExercises / totalExercises;
}
