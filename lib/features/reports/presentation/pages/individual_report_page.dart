import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../../../../../features/students/domain/entities/student_entity.dart';
import '../../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../../../../services/pdf_reporting_service.dart';
import '../../../../../shared/widgets/grade_badge.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../mock/report_mock_data.dart';
import '../widgets/gamification_strip.dart';
import '../widgets/progress_line_chart.dart';
import '../widgets/recent_evaluations_list.dart';
import '../widgets/report_stat_cards.dart';
import '../widgets/subject_performance_bars.dart';

class IndividualReportPage extends StatefulWidget {
  const IndividualReportPage({super.key});

  @override
  State<IndividualReportPage> createState() => _IndividualReportPageState();
}

class _IndividualReportPageState extends State<IndividualReportPage> {
  StudentEntity? _selected;
  late final http.Client _httpClient;
  late final IndividualReportNotifier _reportNotifier;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _reportNotifier = IndividualReportNotifier(
      ReportRepositoryImpl(httpClient: _httpClient),
    );
  }

  @override
  void dispose() {
    _reportNotifier.dispose();
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = context.read<StudentsNotifier>().state.students;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LeftPanel(
          students: students,
          selected: _selected,
          report: _reportNotifier.report,
          onChanged: (s) async {
            setState(() => _selected = s);
            await _reportNotifier.getIndividualReport(s.id);
          },
        ),
        Expanded(
          child: _selected == null
              ? const _EmptyState()
              : AnimatedBuilder(
                  animation: _reportNotifier,
                  builder: (_, __) {
                    if (_reportNotifier.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (_reportNotifier.state == ReportLoadState.error) {
                      return Center(
                        child: Text(
                          _reportNotifier.error ?? 'No se pudo cargar el reporte',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                        ),
                      );
                    }
                    final report = _reportNotifier.report;
                    if (report == null) {
                      return const _EmptyState();
                    }
                    return _RightPanel(report: report);
                  },
                ),
        ),
      ],
    );
  }
}

// â”€â”€ Estado vacÃ­o â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 48, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Selecciona un estudiante',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Su reporte aparecerÃ¡ aquÃ­',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Panel izquierdo
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LeftPanel extends StatefulWidget {
  const _LeftPanel({
    required this.students,
    required this.selected,
    required this.report,
    required this.onChanged,
  });

  final List<StudentEntity>         students;
  final StudentEntity?               selected;
  final IndividualReportEntity?      report;
  final ValueChanged<StudentEntity>  onChanged;

  @override
  State<_LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<_LeftPanel> {
  final _searchController = TextEditingController();
  int?   _gradeFilter;
  List<StudentEntity> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.students;
  }

  @override
  void didUpdateWidget(_LeftPanel old) {
    super.didUpdateWidget(old);
    if (old.students != widget.students) _apply();
  }

  void _apply() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.students.where((s) {
        final matchText  = q.isEmpty || s.fullName.toLowerCase().contains(q);
        final matchGrade = _gradeFilter == null || s.grade == _gradeFilter;
        return matchText && matchGrade;
      }).toList();
    });
  }

  void _setGrade(int? grade) {
    setState(() => _gradeFilter = grade);
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfH = constraints.maxHeight / 2;

          return Column(
            children: [
              // â”€â”€ Mitad superior â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SizedBox(
                height: halfH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md,
                        AppSpacing.md, AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECCIONAR ESTUDIANTE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => _apply(),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      hintText: 'Buscar estudiante...',
                                      prefixIcon: Icon(
                                        Icons.search_rounded, size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _GradeFilterButton(
                                  selected: _gradeFilter,
                                  onSelect: _setGrade,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Expanded(
                      child: _StudentList(
                        students: _filtered,
                        selected: widget.selected,
                        onTap: widget.onChanged,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // â”€â”€ Mitad inferior â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SizedBox(
                height: halfH - 1,
                child: widget.report == null
                    ? Center(
                        child: Text(
                          'Sin evaluaciones',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textHint),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: RecentEvaluationsList(
                                results: widget.report!.resultados,
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _EvalAverageCard(results: widget.report!.resultados),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€ Filtro por grado con hover border animado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GradeFilterButton extends StatefulWidget {
  const _GradeFilterButton({required this.selected, required this.onSelect});

  final int?               selected;
  final ValueChanged<int?> onSelect;

  @override
  State<_GradeFilterButton> createState() => _GradeFilterButtonState();
}

class _GradeFilterButtonState extends State<_GradeFilterButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected != null;

    final Color borderColor;
    if (isActive) {
      borderColor = AppColors.primary;
    } else if (_hovered) {
      borderColor = AppColors.primaryLight;
    } else {
      borderColor = AppColors.border;
    }

    return PopupMenuButton<int?>(
      tooltip: 'Filtrar por grado',
      offset: const Offset(0, 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.medium),
      ),
      color: AppColors.surfaceCard,
      onSelected: widget.onSelect,
      itemBuilder: (_) => [
        PopupMenuItem<int?>(
          value: null,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Todos los grados',
              style: TextStyle(
                color: widget.selected == null
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: widget.selected == null
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ),
        ...AppConstants.grades.map(
          (g) => PopupMenuItem<int?>(
            value: g,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                AppConstants.gradeLabels[g] ?? '$gÂ° grado',
                style: TextStyle(
                  color: widget.selected == g
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: widget.selected == g
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(
              color: borderColor,
              width: isActive || _hovered ? 1.5 : 1.0,
            ),
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Icon(
            Icons.filter_list_rounded,
            size: 18,
            color: isActive
                ? AppColors.primary
                : _hovered
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Lista de estudiantes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StudentList extends StatelessWidget {
  const _StudentList({
    required this.students,
    required this.selected,
    required this.onTap,
  });

  final List<StudentEntity>         students;
  final StudentEntity?               selected;
  final ValueChanged<StudentEntity>  onTap;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron estudiantes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: students.length,
      itemBuilder: (context, i) => _StudentRow(
        student: students[i],
        isSelected: students[i] == selected,
        onTap: () => onTap(students[i]),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.isSelected,
    required this.onTap,
  });

  final StudentEntity student;
  final bool          isSelected;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    final color      = AppColors.forGrade(student.grade);
    final gradeLabel = AppConstants.gradeLabels[student.grade]
        ?? '${student.grade}Â° grado';

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Row(
            children: [
              StudentAvatar(
                initials: student.initials,
                grade: student.grade,
                radius: 18,
                photoUrl: student.photoUrl,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      gradeLabel,
                      style: TextStyle(
                        fontSize: 11, color: color,
                        fontWeight: FontWeight.w600, fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18, color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Promedio de evaluaciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EvalAverageCard extends StatelessWidget {
  const _EvalAverageCard({required this.results});
  final List<dynamic> results;

  int get _avg {
    if (results.isEmpty) return 0;
    final sum = results.fold<int>(0, (acc, r) => acc + (r.puntuacion as int));
    return (sum / results.length).round();
  }

  Color _color(int pct) {
    if (pct >= 75) return AppColors.primary;
    if (pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final avg   = _avg;
    final color = _color(avg);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: const BorderRadius.all(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promedio de evaluaciones',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$avg%',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: color, fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.bar_chart_rounded, color: color, size: 28),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Panel derecho â€” adaptable: sin scroll en pantallas grandes, con scroll si hace falta
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.report});
  final IndividualReportEntity report;

  List<SubjectPerformance> get _subjectPerformance {
    return report.rendimientoPorMateria
        .map(
          (s) => SubjectPerformance(
            name: s.nombre,
            color: SubjectColors.forName(s.nombre),
            reading: s.lectura,
            writing: s.escritura,
          ),
        )
        .toList();
  }

  List<WeekPoint> get _progressHistory {
    return report.progresoSemanal
        .map((p) => WeekPoint(week: p.week, value: p.value))
        .toList();
  }

  List<BadgeData> get _badges {
    if (report.insignias.isEmpty) return const [];
    return report.insignias.take(2).map((name) {
      final n = name.toLowerCase();
      if (n.contains('racha')) {
        return const BadgeData(
          icon: Icons.local_fire_department_rounded,
          label: 'Racha activa',
          color: Color(0xFFEF4444),
        );
      }
      if (n.contains('lector')) {
        return const BadgeData(
          icon: Icons.star_rounded,
          label: 'Lector estrella',
          color: Color(0xFFF59E0B),
        );
      }
      return BadgeData(
        icon: Icons.emoji_events_rounded,
        label: name,
        color: const Color(0xFF10B981),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gradeLabel =
        AppConstants.gradeLabels[report.estudianteGrado] ??
        '${report.estudianteGrado}Â° grado';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudentHeader(report: report, gradeLabel: gradeLabel),
            const SizedBox(height: AppSpacing.sm),
            ReportStatCards(report: report),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              child: SubjectPerformanceBars(
                subjects: _subjectPerformance,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              child: ProgressLineChart(
                points: _progressHistory,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              child: GamificationStrip(
                ranking: report.ranking,
                xp: report.xpPoints,
                levelName: report.levelName,
                badges: _badges,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.report, required this.gradeLabel});
  final IndividualReportEntity report;
  final String                 gradeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.estudianteNombre} - $gradeLabel',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'Activa - Ultima actividad: hoy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () =>
              PdfReportingService.generateIndividualReportPdf(report),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Exportar PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
              fontSize: 13,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.medium),
            ),
          ).copyWith(
            mouseCursor: const WidgetStatePropertyAll(
              SystemMouseCursors.click,
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Card contenedora â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

