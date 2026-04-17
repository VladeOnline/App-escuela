import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/students/domain/entities/student_entity.dart';
import '../../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/historial_table.dart';
import '../widgets/student_selector_panel.dart';

/// Tab "Historial": selector de estudiante + tabla completa de evaluaciones.
class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  StudentEntity? _selected;
  late final HistorialNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = HistorialNotifier(
      ReportRepositoryImpl(httpClient: http.Client()),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _onStudentChanged(StudentEntity student) async {
    setState(() => _selected = student);
    await _notifier.getHistorial(student.id);
  }

  @override
  Widget build(BuildContext context) {
    final students = context.read<StudentsNotifier>().state.students;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Selector izquierdo ────────────────────────────────
        Container(
          width: 290,
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: StudentSelectorPanel(
            students: students,
            selectedStudent: _selected,
            onChanged: _onStudentChanged,
          ),
        ),

        // ── Tabla principal ───────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selected != null) ...[
                  Text(
                    'Historial — ${_selected!.fullName}',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                ListenableBuilder(
                  listenable: _notifier,
                  builder: (context, _) {
                    if (_notifier.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (_notifier.state == ReportLoadState.error) {
                      return _ErrorBanner(message: _notifier.error);
                    }
                    if (_notifier.historial == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Text(
                            'Selecciona un estudiante para ver su historial',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textHint,
                                    ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius:
                            const BorderRadius.all(AppRadius.large),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: HistorialTable(
                        historial: _notifier.historial!,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: const BorderRadius.all(AppRadius.large),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? 'Error al cargar el historial',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
