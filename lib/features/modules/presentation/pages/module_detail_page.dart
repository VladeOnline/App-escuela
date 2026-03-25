import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/confirm_dialog.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import 'exercise_detail_page.dart';
import 'exercise_form_page.dart';

/// Página de un módulo: lista todos sus ejercicios.
///
/// El docente puede crear nuevos ejercicios (RF-09) y activar/desactivar
/// los existentes (RF-12). El botón de nuevo ejercicio abre ExerciseFormPage.
class ModuleDetailPage extends StatefulWidget {
  const ModuleDetailPage({
    super.key,
    required this.module,
    required this.repository,
    this.isTeacher = true,
  });

  final ModuleEntity module;
  final MockModuleRepository repository;

  /// Si es false (vista alumno), oculta controles de administración.
  final bool isTeacher;

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  late List<ExerciseEntity> _exercises;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _exercises =
          widget.repository.getExercisesByModule(widget.module.id);
    });
  }

  Future<void> _onCreateExercise() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExerciseFormPage(
          moduleId: widget.module.id,
          moduleTitle: widget.module.title,
          repository: widget.repository,
        ),
      ),
    );
    if (created == true) _reload();
  }

  Future<void> _onToggleExercise(ExerciseEntity exercise) async {
    final action = exercise.isActive ? 'desactivar' : 'activar';
    final confirmed = await ConfirmDialog.show(
      context,
      title: '${action[0].toUpperCase()}${action.substring(1)} ejercicio',
      content:
          '¿Seguro que quieres $action "${exercise.title}"?',
      confirmLabel: action[0].toUpperCase() + action.substring(1),
      cancelLabel: 'Cancelar',
      isDestructive: !exercise.isActive ? false : true,
      icon: exercise.isActive
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
    );
    if (confirmed) {
      await widget.repository.toggleExercise(exercise.id);
      _reload();
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          'Ejercicio ${exercise.isActive ? 'desactivado' : 'activado'} correctamente',
        );
      }
    }
  }

  Future<void> _onOpenExercise(ExerciseEntity exercise) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailPage(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _exercises.where((e) => e.isActive).toList();
    final inactive = _exercises.where((e) => !e.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.module.title),
        actions: [
          if (widget.isTeacher)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: FilledButton.icon(
                onPressed: _onCreateExercise,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nuevo ejercicio'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del módulo
                _ModuleHeader(module: widget.module),
                const SizedBox(height: AppSpacing.lg),

                // Ejercicios activos
                if (active.isEmpty && inactive.isEmpty)
                  _EmptyState(onAdd: widget.isTeacher ? _onCreateExercise : null)
                else ...[
                  if (active.isNotEmpty) ...[
                    _SectionLabel(
                      label: 'Ejercicios disponibles',
                      count: active.length,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ExerciseGrid(
                      exercises: active,
                      isTeacher: widget.isTeacher,
                      onOpen: _onOpenExercise,
                      onToggle: _onToggleExercise,
                    ),
                  ],

                  // Ejercicios inactivos (solo docente los ve)
                  if (inactive.isNotEmpty && widget.isTeacher) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(
                      label: 'Desactivados',
                      count: inactive.length,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ExerciseGrid(
                      exercises: inactive,
                      isTeacher: widget.isTeacher,
                      onOpen: _onOpenExercise,
                      onToggle: _onToggleExercise,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header del módulo ────────────────────────────────────────────────────────

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module});
  final ModuleEntity module;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: const BorderRadius.all(AppRadius.large),
            ),
            child: Icon(module.type.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.school_rounded,
                      label: '${module.grade}° grado',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _Chip(
                      icon: Icons.assignment_outlined,
                      label: '${module.exerciseCount} ejercicios',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grid de ejercicios ───────────────────────────────────────────────────────

class _ExerciseGrid extends StatelessWidget {
  const _ExerciseGrid({
    required this.exercises,
    required this.isTeacher,
    required this.onOpen,
    required this.onToggle,
  });

  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final ValueChanged<ExerciseEntity> onOpen;
  final ValueChanged<ExerciseEntity> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 700 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.6,
          ),
          itemCount: exercises.length,
          itemBuilder: (_, i) => _ExerciseCard(
            exercise: exercises[i],
            isTeacher: isTeacher,
            onOpen: onOpen,
            onToggle: onToggle,
          ),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isTeacher,
    required this.onOpen,
    required this.onToggle,
  });

  final ExerciseEntity exercise;
  final bool isTeacher;
  final ValueChanged<ExerciseEntity> onOpen;
  final ValueChanged<ExerciseEntity> onToggle;

  @override
  Widget build(BuildContext context) {
    final isInactive = !exercise.isActive;

    return Opacity(
      opacity: isInactive ? 0.5 : 1.0,
      child: Card(
        child: InkWell(
          onTap: isInactive && !isTeacher
              ? null
              : () => onOpen(exercise),
          borderRadius: const BorderRadius.all(AppRadius.large),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícono de tipo
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: exercise.difficulty.color.withOpacity(0.12),
                        borderRadius:
                            const BorderRadius.all(AppRadius.medium),
                      ),
                      child: Icon(
                        _typeIcon(exercise.type),
                        color: exercise.difficulty.color,
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    // Badge de dificultad
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            exercise.difficulty.color.withOpacity(0.10),
                        borderRadius: const BorderRadius.all(AppRadius.full),
                      ),
                      child: Text(
                        exercise.difficulty.label,
                        style: TextStyle(
                          color: exercise.difficulty.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                    // Menú del docente
                    if (isTeacher) ...[
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            size: 16, color: AppColors.textHint),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(children: [
                              Icon(
                                exercise.isActive
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(exercise.isActive
                                  ? 'Desactivar'
                                  : 'Activar'),
                            ]),
                          ),
                        ],
                        onSelected: (_) => onToggle(exercise),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Text(
                  exercise.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_typeIcon(exercise.type),
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      exercise.type.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                    const Spacer(),
                    const Icon(Icons.stars_rounded,
                        size: 12, color: AppColors.secondary),
                    const SizedBox(width: 2),
                    Text(
                      '${exercise.points} pts',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 11,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(ExerciseType type) => switch (type) {
        ExerciseType.multipleChoice => Icons.radio_button_checked_rounded,
        ExerciseType.trueOrFalse => Icons.check_circle_outline_rounded,
        ExerciseType.fillInTheBlank => Icons.text_fields_rounded,
        ExerciseType.ordering => Icons.sort_rounded,
      };
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.full),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onAdd});
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No hay ejercicios aún',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              onAdd != null
                  ? 'Crea el primer ejercicio para este módulo.'
                  : 'El docente aún no ha agregado ejercicios.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onAdd != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Crear ejercicio'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
