import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/api_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/modules/grade_section.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({
    super.key,
    required this.moduleType,
    required this.repository,
    this.isTeacher = true,
    this.studentGrade,
  });

  final ModuleType moduleType;
  final ApiModuleRepository repository; // CAMBIO: Api en vez de Mock
  final bool isTeacher;
  final int? studentGrade;

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  List<ModuleEntity> _modules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await widget.repository.getModulesByType(widget.moduleType);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.failure != null) {
        _errorMessage = result.failure!.message;
      } else {
        _modules = result.modules;
      }
    });
  }

  List<ModuleEntity> _modulesForGrade(int grade) =>
      _modules.where((m) => m.grade == grade).toList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModulesHeader(moduleType: widget.moduleType),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(fontFamily: 'Nunito', color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadModules,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadModules,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        itemCount: AppConstants.grades.length,
        itemBuilder: (_, i) {
          final grade = AppConstants.grades[i];
          return GradeSection(
            grade: grade,
            modules: _modulesForGrade(grade),
            repository: widget.repository,
            isTeacher: widget.isTeacher,
            moduleType: widget.moduleType,   
            onCreated: _loadModules,
          );
        },
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
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 6, right: 80,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
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
                  color: Colors.white.withOpacity(0.18),
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
                      color: Colors.white.withOpacity(0.80),
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