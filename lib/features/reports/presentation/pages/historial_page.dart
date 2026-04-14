import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../../features/students/domain/entities/student_entity.dart';
import '../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../notifiers/report_notifier.dart';
import '../widgets/historial_table.dart';
import '../widgets/student_selector.dart';

/// Página de historial de evaluaciones
class HistorialPage extends StatefulWidget {
  const HistorialPage({Key? key}) : super(key: key);

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  StudentEntity? _selectedStudent;
  late HistorialNotifier _historialNotifier;

  @override
  void initState() {
    super.initState();
    final repository = ReportRepositoryImpl(httpClient: http.Client());
    _historialNotifier = HistorialNotifier(repository);
  }

  @override
  void dispose() {
    _historialNotifier.dispose();
    super.dispose();
  }

  Future<void> _onStudentSelected(StudentEntity? student) async {
    setState(() {
      _selectedStudent = student;
    });

    if (student != null) {
      await _historialNotifier.getHistorial(student.id);
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
            'Historial de Evaluaciones',
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
            listenable: _historialNotifier,
            builder: (context, _) {
              if (_historialNotifier.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_historialNotifier.state == ReportLoadState.error) {
                return _buildErrorWidget();
              }

              if (_historialNotifier.historial == null) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  child: Text(
                    'Selecciona un estudiante para ver su historial',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              final historial = _historialNotifier.historial!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas
                  HistorialStats(historial: historial),
                  const SizedBox(height: AppSpacing.xl),

                  // Título
                  Text(
                    'Detalle de Evaluaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tabla
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: HistorialTable(historial: historial),
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
            'Error al cargar historial',
            style: TextStyle(color: Colors.red[700]),
          ),
          if (_historialNotifier.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _historialNotifier.error!,
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
