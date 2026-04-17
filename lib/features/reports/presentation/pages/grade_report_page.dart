import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/grade_badge.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/grade_report_entity.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/grade_report_summary.dart';

/// Tab "Por Grado": selector de grado + estadísticas del grupo.
class GradeReportPage extends StatefulWidget {
  const GradeReportPage({super.key});

  @override
  State<GradeReportPage> createState() => _GradeReportPageState();
}

class _GradeReportPageState extends State<GradeReportPage> {
  int? _selectedGrade;
  late final GradeReportNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = GradeReportNotifier(
      ReportRepositoryImpl(httpClient: http.Client()),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _select(int grade) async {
    setState(() => _selectedGrade = grade);
    await _notifier.getGradeReport(grade);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte por Grado',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Selecciona un grado para ver el rendimiento del grupo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Selector de grado ──────────────────────────────────
          _GradeSelector(
            selected: _selectedGrade,
            onSelect: _select,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Contenido del reporte ──────────────────────────────
          ListenableBuilder(
            listenable: _notifier,
            builder: (context, _) {
              if (_notifier.isLoading) {
                return const _LoadingState();
              }
              if (_notifier.state == ReportLoadState.error) {
                return _ErrorState(message: _notifier.error);
              }
              if (_notifier.report == null) {
                return const _EmptyState(
                  message: 'Selecciona un grado para ver el reporte',
                );
              }
              return _ReportContent(report: _notifier.report!);
            },
          ),
        ],
      ),
    );
  }
}

// ── Grade selector chips ───────────────────────────────────────────────────────

class _GradeSelector extends StatelessWidget {
  const _GradeSelector({required this.selected, required this.onSelect});

  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppConstants.grades.map((g) {
        final isSelected = selected == g;
        final color = AppColors.forGrade(g);
        return GestureDetector(
          onTap: () => onSelect(g),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : AppColors.surfaceCard,
              borderRadius: const BorderRadius.all(AppRadius.full),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              AppConstants.gradeLabels[g] ?? '$g° grado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.textSecondary,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Report content ────────────────────────────────────────────────────────────

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.report});
  final GradeReportEntity report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: GradeReportSummary(report: report),
    );
  }
}

// ── State helpers ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: const BorderRadius.all(AppRadius.large),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? 'Error al cargar el reporte',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textHint,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
