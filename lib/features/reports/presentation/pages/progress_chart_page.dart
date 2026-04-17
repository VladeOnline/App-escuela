import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/students/domain/entities/student_entity.dart';
import '../../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../mock/report_mock_data.dart';
import '../widgets/progress_line_chart.dart';
import '../widgets/student_selector_panel.dart';

/// Tab "Progreso": selector de estudiante + gráfico de evolución del promedio.
///
/// TODO(back): conectar [ProgressChartNotifier] cuando el endpoint esté listo.
class ProgressChartPage extends StatefulWidget {
  const ProgressChartPage({super.key});

  @override
  State<ProgressChartPage> createState() => _ProgressChartPageState();
}

class _ProgressChartPageState extends State<ProgressChartPage> {
  StudentEntity? _selected;

  @override
  Widget build(BuildContext context) {
    final students = context.read<StudentsNotifier>().state.students;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Selector izquierdo ──────────────────────────────────
        Container(
          width: 290,
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: StudentSelectorPanel(
            students: students,
            selectedStudent: _selected,
            onChanged: (s) => setState(() => _selected = s),
          ),
        ),

        // ── Contenido principal ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selected != null) ...[
                  Text(
                    '${_selected!.fullName} — Evolución del promedio',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _SectionCard(
                  child: ProgressLineChart(
                    points: ReportMockData.progressHistory,
                  ),
                ),
                if (_selected == null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: Text(
                      'Selecciona un estudiante para ver su progreso',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textHint,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
