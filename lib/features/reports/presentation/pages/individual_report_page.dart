import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../../features/students/domain/entities/student_entity.dart';
import '../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/report_summary.dart';
import '../widgets/results_table.dart';
import '../widgets/student_selector.dart';

/// Página de reportes individuales de estudiantes
class IndividualReportPage extends StatefulWidget {
  const IndividualReportPage({Key? key}) : super(key: key);

  @override
  State<IndividualReportPage> createState() => _IndividualReportPageState();
}

class _IndividualReportPageState extends State<IndividualReportPage> {
  StudentEntity? _selectedStudent;
  late IndividualReportNotifier _reportNotifier;

  @override
  void initState() {
    super.initState();
    // Inicializar el repositorio y el notifier
    final repository = ReportRepositoryImpl(httpClient: http.Client());
    _reportNotifier = IndividualReportNotifier(repository);
  }

  @override
  void dispose() {
    _reportNotifier.dispose();
    super.dispose();
  }

  Future<void> _onStudentSelected(StudentEntity? student) async {
    setState(() {
      _selectedStudent = student;
    });

    if (student != null) {
      await _reportNotifier.getIndividualReport(student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsNotifier = context.read<StudentsNotifier>();
    final students = studentsNotifier.state.students;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Reportes Individuales',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Selector de estudiante
          StudentSelector(
            students: students,
            selectedStudent: _selectedStudent,
            onChanged: _onStudentSelected,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Contenido del reporte
          ListenableBuilder(
            listenable: _reportNotifier,
            builder: (context, _) {
              if (_reportNotifier.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_reportNotifier.state == ReportLoadState.error) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Error al cargar reporte',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      if (_reportNotifier.error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _reportNotifier.error!,
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                );
              }

              if (_reportNotifier.report == null) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  child: Text(
                    'Selecciona un estudiante para ver su reporte',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              final report = _reportNotifier.report!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen
                  ReportSummary(report: report),
                  const SizedBox(height: AppSpacing.xl),

                  // Título de resultados
                  Text(
                    'Historial de Evaluaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tabla de resultados
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ResultsTable(report: report),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
