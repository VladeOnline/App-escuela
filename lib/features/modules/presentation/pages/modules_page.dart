import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/modules/grade_section.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({
    super.key,
    required this.moduleType,
    required this.repository,
    this.isTeacher = true,
    this.studentGrade,
  });

  final ModuleType moduleType;
  final MockModuleRepository repository;
  final bool isTeacher;
  final int? studentGrade;

  List<ModuleEntity> _modulesForGrade(int grade) =>
      repository.getModulesByType(moduleType).where((m) => m.grade == grade).toList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModulesHeader(moduleType: moduleType),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
              ),
              itemCount: AppConstants.grades.length,
              itemBuilder: (_, i) {
                final grade = AppConstants.grades[i];
                return GradeSection(
                  grade: grade,
                  modules: _modulesForGrade(grade),
                  repository: repository,
                  isTeacher: isTeacher,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulesHeader extends StatelessWidget {
  const _ModulesHeader({required this.moduleType});
  final ModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18, right: -12,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 6, right: 80,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg,
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                ),
                child: Icon(moduleType.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Módulos de ${moduleType.label}',
                    style: const TextStyle(
                      fontSize: 20, fontFamily: 'Nunito',
                      color: Colors.white, fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Selecciona un módulo para comenzar',
                    style: TextStyle(
                      fontSize: 12, fontFamily: 'Nunito',
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

