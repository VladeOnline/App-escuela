import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/grade_report_summary.dart';
import '../widgets/results_table.dart';

/// Página de reportes por grado
class GradeReportPage extends StatefulWidget {
  const GradeReportPage({Key? key}) : super(key: key);

  @override
  State<GradeReportPage> createState() => _GradeReportPageState();
}

class _GradeReportPageState extends State<GradeReportPage> {
  int? _selectedGrade;
  late GradeReportNotifier _gradeNotifier;

  @override
  void initState() {
    super.initState();
    final repository = ReportRepositoryImpl(httpClient: http.Client());
    _gradeNotifier = GradeReportNotifier(repository);
  }

  @override
  void dispose() {
    _gradeNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadGradeReport(int grado) async {
    setState(() {
      _selectedGrade = grado;
    });
    await _gradeNotifier.getGradeReport(grado);
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Selector de grado
          Text(
            'Seleccionar Grado',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: AppConstants.grades.map((grado) {
              final isSelected = _selectedGrade == grado;
              return ElevatedButton(
                onPressed: () => _loadGradeReport(grado),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Grado $grado'),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Contenido del reporte
          ListenableBuilder(
            listenable: _gradeNotifier,
            builder: (context, _) {
              if (_gradeNotifier.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_gradeNotifier.state == ReportLoadState.error) {
                return _buildErrorWidget();
              }

              if (_gradeNotifier.report == null) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  child: Text(
                    'Selecciona un grado para ver el reporte',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              final report = _gradeNotifier.report!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen
                  GradeReportSummary(report: report),
                  const SizedBox(height: AppSpacing.xl),

                  // Título de estudiantes
                  Text(
                    'Resultados por Estudiante',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tabla de resultados
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ResultsTable(
                      report: report.resultados.isEmpty
                          ? null
                          : _convertToIndividualReport(report),
                    ),
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

  Widget _buildErrorWidget() {
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
          if (_gradeNotifier.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _gradeNotifier.error!,
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

  // Convertir GradeReport a IndividualReport para mostrar en ResultsTable
  dynamic _convertToIndividualReport(dynamic report) {
    // Simplemente retornamos el reporte ya que ResultsTable puede trabajar con cualquier
    // estructura que tenga resultados
    return report;
  }
}
