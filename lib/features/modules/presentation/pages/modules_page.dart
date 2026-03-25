import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import 'module_detail_page.dart';

/// Página de listado de módulos por tipo (Lectura o Escritura).
///
/// Muestra las tarjetas de cada módulo disponible.
/// Recibe [moduleType] para saber qué lista cargar.
/// El docente ve todos; el alumno solo los activos de su grado.
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

  /// Si es alumno, filtra por su grado.
  final int? studentGrade;

  List<ModuleEntity> get _modules {
    final all = repository.getModulesByType(moduleType);
    if (!isTeacher && studentGrade != null) {
      return all.where((m) => m.grade == studentGrade).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final modules = _modules;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(moduleType.icon, size: 20),
            const SizedBox(width: 8),
            Text('Módulos de ${moduleType.label}'),
          ],
        ),
      ),
      body: modules.isEmpty
          ? _EmptyState(moduleType: moduleType)
          : _ModuleGrid(
              modules: modules,
              repository: repository,
              isTeacher: isTeacher,
            ),
    );
  }
}

// ─── Grid de módulos ──────────────────────────────────────────────────────────

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({
    required this.modules,
    required this.repository,
    required this.isTeacher,
  });

  final List<ModuleEntity> modules;
  final MockModuleRepository repository;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth > 800 ? 3 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.5,
            ),
            itemCount: modules.length,
            itemBuilder: (_, i) => _ModuleCard(
              module: modules[i],
              repository: repository,
              isTeacher: isTeacher,
            ),
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.repository,
    required this.isTeacher,
  });

  final ModuleEntity module;
  final MockModuleRepository repository;
  final bool isTeacher;

  void _onTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModuleDetailPage(
          module: module,
          repository: repository,
          isTeacher: isTeacher,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppColors.forGrade(module.grade);

    return Card(
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: const BorderRadius.all(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícono del módulo
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                    ),
                    child: Icon(module.type.icon,
                        color: AppColors.primary, size: 22),
                  ),
                  const Spacer(),
                  // Badge de grado
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.12),
                      borderRadius: const BorderRadius.all(AppRadius.full),
                    ),
                    child: Text(
                      '${module.grade}° grado',
                      style: TextStyle(
                        color: gradeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                module.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Footer: ejercicios + flecha
              Row(
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${module.exerciseCount} ejercicios',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.moduleType});
  final ModuleType moduleType;

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
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(moduleType.icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No hay módulos de ${moduleType.label}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Los módulos estarán disponibles próximamente.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
