import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../../features/students/data/repositories/mock_student_repository.dart';
import '../../../../features/students/domain/usecases/validate_student_usecase.dart';
import '../../../../features/modules/data/repositories/mock_module_repository.dart';
import '../../../../features/modules/domain/entities/module_entities.dart';
import '../../../../features/modules/presentation/pages/modules_page.dart';
import '../../../../features/students/presentation/pages/student_list_page.dart';
import '../widgets/dashboard/stats_overview_row.dart';
import '../widgets/layout/teacher_sidebar.dart';
import '../widgets/layout/teacher_topbar.dart';
import '../../../students/presentation/notifiers/students_notifier.dart';

/// Shell principal del panel docente.
///
/// Responsabilidad: componer el layout (sidebar + topbar + contenido).
/// No contiene lógica de UI propia — delega a widgets especializados.
///
/// Índices de navegación:
///   0 → Inicio (dashboard + lista de estudiantes)
///   1 → Módulos / Lectura
///   2 → Módulos / Escritura
///   3 → Reportes
///   4 → Ajustes
class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  int _selectedIndex = 0;

  /// Repositorio mock — el Back lo reemplazará con la implementación real.
  late final StudentsNotifier _studentsNotifier = StudentsNotifier(
    repository: MockStudentRepository(),
    validator: const ValidateStudentUseCase(),
  );

  // Repositorio de módulos — compartido entre Lectura y Escritura.
  final _moduleRepository = MockModuleRepository();

  static const _sectionTitles = {
    0: 'Inicio',
    1: 'Módulos — Lectura',
    2: 'Módulos — Escritura',
    3: 'Reportes',
    4: 'Ajustes',
  };

  @override
  void dispose() {
    _studentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _onLogout() async {
    context.read<AuthNotifier>().logout();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  String get _teacherName {
    // TODO(back): obtener el nombre real desde AuthNotifier cuando el Back conecte.
    // context.read<AuthNotifier>().state.userName ?? 'Profesor'
    return 'Juan';
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return _DashboardView(notifier: _studentsNotifier);
      case 1:
        return ModulesPage(
          moduleType: ModuleType.reading,
          repository: _moduleRepository,
        );
      case 2:
        return ModulesPage(
          moduleType: ModuleType.writing,
          repository: _moduleRepository,
        );
      case 3:
        return _ComingSoonView(label: _sectionTitles[index] ?? '');
      case 4:
        return _ComingSoonView(label: _sectionTitles[index] ?? '');
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          TeacherSidebar(
            selectedIndex: _selectedIndex,
            teacherName: _teacherName,
            onSelectIndex: (i) => setState(() => _selectedIndex = i),
            onLogout: _onLogout,
          ),

          // ── Contenido principal ──
          Expanded(
            child: Column(
              children: [
                TeacherTopbar(
                  title: _sectionTitles[_selectedIndex] ?? 'Inicio',
                  teacherName: _teacherName,
                  onLogout: _onLogout,
                ),
                Expanded(child: _buildContent(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vista de Inicio (dashboard + lista de estudiantes) ───────────────────────

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.notifier});

  final StudentsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini-dashboard de estadísticas
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Su distribución este año',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              StatsOverviewRow.mock(),
            ],
          ),
        ),

        // Divisor visual entre dashboard y lista
        const Divider(height: 1, color: AppColors.border),

        // Lista de estudiantes (ocupa el resto del espacio disponible)
        Expanded(
          child: StudentListPage(notifier: notifier),
        ),
      ],
    );
  }
}

// ─── Placeholder para secciones futuras ──────────────────────────────────────

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.construction_rounded,
              size: 40,
              color: AppColors.secondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Esta sección estará disponible en el próximo sprint',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
