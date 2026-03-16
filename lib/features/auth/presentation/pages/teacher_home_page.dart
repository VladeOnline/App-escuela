import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/data/repositories/mock_student_repository.dart';
import '../../../students/domain/usecases/validate_student_usecase.dart';
import '../../../students/presentation/bloc/students_notifier.dart';
import '../../../students/presentation/pages/student_list_page.dart';

/// Pantalla principal del docente.
/// Shell con navegación lateral para las secciones del Sprint 1.
/// Se irán agregando secciones conforme avancen los sprints.
class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  // Repositorio mock — el Back lo reemplazará con la implementación real.
  late final StudentsNotifier _studentsNotifier = StudentsNotifier(
    repository: MockStudentRepository(),
    validator: const ValidateStudentUseCase(),
  );

  final _navItems = const [
    _NavItem(
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      label: 'Estudiantes',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Contenido',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Reportes',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Ajustes',
    ),
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return StudentListPage(notifier: _studentsNotifier);
      case 1:
      case 2:
      case 3:
        return _ComingSoonPage(label: _navItems[index].label);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _studentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _onLogout() async {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar de navegación
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            extended: false,
            minWidth: 72,
            backgroundColor: AppColors.surfaceCard,
            indicatorColor: AppColors.primary.withOpacity(0.12),
            selectedIconTheme:
                const IconThemeData(color: AppColors.primary, size: 24),
            unselectedIconTheme:
                const IconThemeData(color: AppColors.textHint, size: 22),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              fontFamily: 'Nunito',
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontFamily: 'Nunito',
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textHint,
                  size: 22,
                ),
                tooltip: 'Cerrar sesión',
                onPressed: _onLogout,
              ),
            ),
            destinations: _navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          // Divisor
          Container(width: 1, color: AppColors.border),
          // Contenido principal
          Expanded(child: _buildPage(_selectedIndex)),
        ],
      ),
    );
  }
}

// ─── Placeholder para secciones futuras ──────────────────────────────────────

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.label});
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
              color: AppColors.secondary.withOpacity(0.1),
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

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
