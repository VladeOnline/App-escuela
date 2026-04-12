import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/repositories/api_module_repository.dart';
import '../../../domain/entities/module_entities.dart';
import '../../pages/content_form_page.dart'; // ← nueva página
import 'create_module_card.dart';
import 'module_card.dart';

// ─── Sección por grado ────────────────────────────────────────────────────────

class GradeSection extends StatelessWidget {
  const GradeSection({
    super.key,
    required this.grade,
    required this.modules,
    required this.repository,
    required this.isTeacher,
    required this.moduleType,
    required this.onCreated,
  });

  final int grade;
  final List<ModuleEntity> modules;
  final ApiModuleRepository repository;
  final bool isTeacher;
  final ModuleType moduleType;
  final VoidCallback onCreated;

  static const _gradeNames = {
    1: 'Primer grado',  2: 'Segundo grado', 3: 'Tercer grado',
    4: 'Cuarto grado',  5: 'Quinto grado',  6: 'Sexto grado',
  };

  /// Navega a ContentFormPage y recarga si se creó algo.
  Future<void> _goToCreateContent(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ContentFormPage(
          moduleType: moduleType,
          grade: grade,
          repository: repository,
        ),
      ),
    );
    if (created == true) onCreated();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGrade(grade);
    final name  = _gradeNames[grade] ?? '$grade° grado';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado del grado ───────────────────────────────────────
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: const BorderRadius.all(AppRadius.medium),
              ),
              child: Icon(Icons.school_rounded, color: color, size: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(name,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito', color: color)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.35), Colors.transparent],
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // ── Cards o estado vacío ───────────────────────────────────────
          if (modules.isEmpty)
            GradeEmptyState(
              color: color,
              gradeName: name,
              // ← ahora pasa el callback real en vez del snackbar
              onCreateTap: () => _goToCreateContent(context),
            )
          else
            LayoutBuilder(builder: (_, constraints) {
              const cols    = 3;
              const spacing = AppSpacing.sm;
              final cardW   = ((constraints.maxWidth - spacing * (cols - 1)) / cols) * 0.9;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  ...modules.map((m) => SizedBox(
                    width: cardW,
                    height: 190,
                    child: ModuleCard(
                      module: m,
                      repository: repository,
                      isTeacher: isTeacher,
                      onDeleted: onCreated,
                    ),
                  )),
                  SizedBox(
                    width: cardW,
                    height: 190,
                    child: CreateModuleCard(
                      repository: repository,
                      moduleType: modules.isNotEmpty ? modules.first.type : ModuleType.reading,
                      grade: grade,
                      onCreated: onCreated,
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── Estado vacío de grado ────────────────────────────────────────────────────

class GradeEmptyState extends StatelessWidget {
  const GradeEmptyState({
    super.key,
    required this.color,
    required this.gradeName,
    required this.onCreateTap, // ← antes no existía; era un snackbar hardcodeado
  });

  final Color color;
  final String gradeName;
  final VoidCallback onCreateTap; // ← NUEVO

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sentiment_dissatisfied_rounded, size: 26,
                color: color.withOpacity(0.5)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No hay ejercicios para $gradeName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          // ── Antes: snackbar "Esta función aún no está disponible 🚧"
          // ── Ahora: navega a ContentFormPage
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onCreateTap,
              child: Text(
                '¡Empieza a crearlos →!',
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  decoration: TextDecoration.underline,
                  decorationColor: color.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}