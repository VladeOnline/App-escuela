import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../../features/students/domain/entities/student_entity.dart';
import '../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/student_selector.dart';

/// Página de gráficas de progreso
class ProgressChartPage extends StatefulWidget {
  const ProgressChartPage({Key? key}) : super(key: key);

  @override
  State<ProgressChartPage> createState() => _ProgressChartPageState();
}

class _ProgressChartPageState extends State<ProgressChartPage> {
  StudentEntity? _selectedStudent;
  late ProgressChartNotifier _chartNotifier;

  @override
  void initState() {
    super.initState();
    final repository = ReportRepositoryImpl(httpClient: http.Client());
    _chartNotifier = ProgressChartNotifier(repository);
  }

  @override
  void dispose() {
    _chartNotifier.dispose();
    super.dispose();
  }

  Future<void> _onStudentSelected(StudentEntity? student) async {
    setState(() {
      _selectedStudent = student;
    });

    if (student != null) {
      await _chartNotifier.getProgressChart(student.id);
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
          Text(
            'Gráfica de Progreso',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          StudentSelector(
            students: students,
            selectedStudent: _selectedStudent,
            onChanged: _onStudentSelected,
          ),
          const SizedBox(height: AppSpacing.xl),
          ListenableBuilder(
            listenable: _chartNotifier,
            builder: (context, _) {
              if (_chartNotifier.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_chartNotifier.state == ReportLoadState.error) {
                return _buildErrorWidget();
              }

              if (_chartNotifier.chart == null) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  child: Text(
                    'Selecciona un estudiante para ver su progreso',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ProgressChart(chart: _chartNotifier.chart!),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
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
            'Error al cargar gráfica',
            style: TextStyle(color: Colors.red[700]),
          ),
          if (_chartNotifier.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _chartNotifier.error!,
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
}
