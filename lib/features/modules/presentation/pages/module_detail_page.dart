import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/confirm_dialog.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/module_detail/difficulty_section.dart';
import '../widgets/module_detail/exercises_empty_state.dart';
import '../widgets/module_detail/header_decorative_figures.dart';
import '../widgets/module_detail/info_panel.dart';
import '../widgets/module_detail/module_header_card.dart';
import '../widgets/module_detail/selection_action_bar.dart';
import 'exercise_detail_page.dart';
import 'exercise_form_page.dart';
class ModuleDetailPage extends StatefulWidget {
  const ModuleDetailPage({
    super.key,
    required this.module,
    required this.repository,
    this.isTeacher = true,
  });

  final ModuleEntity module;
  final MockModuleRepository repository;
  final bool isTeacher;

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  late List<ExerciseEntity> _exercises;
  Subject? _subjectFilter;
  DifficultyLevel? _selectionLevel;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => setState(() {
        _exercises = widget.repository.getExercisesByModule(widget.module.id);
      });

  List<ExerciseEntity> get _filteredExercises => _subjectFilter == null
      ? _exercises
      : _exercises.where((e) => e.subject == _subjectFilter).toList();

  List<ExerciseEntity> _byLevel(DifficultyLevel d) =>
      _filteredExercises.where((e) => e.difficulty == d).toList();

  // ─── Acciones de ejercicios ───

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

  // TODO(connect): cuando ExerciseFormPage soporte [preselectedLevel], reemplazar
  // _onCreateExercise en _buildSections por este método para preseleccionar el nivel.
  // Future<void> _onCreateExerciseForLevel(DifficultyLevel level) async {
  //   final created = await Navigator.of(context).push<bool>(
  //     MaterialPageRoute(
  //       builder: (_) => ExerciseFormPage(
  //         moduleId: widget.module.id,
  //         moduleTitle: widget.module.title,
  //         repository: widget.repository,
  //         preselectedLevel: level,   // ← parámetro pendiente en ExerciseFormPage
  //       ),
  //     ),
  //   );
  //   if (created == true) _reload();
  // }

  Future<void> _onTapExercise(ExerciseEntity exercise) async {
    if (_selectionLevel != null) {
      _toggleSelected(exercise.id);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExerciseDetailPage(exercise: exercise)),
    );
  }

  Future<void> _onDeleteExercise(ExerciseEntity exercise) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar ejercicio',
      content: '¿Seguro que quieres eliminar "${exercise.title}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await widget.repository.deleteExercise(exercise.id);
    _reload();
    if (mounted) AppSnackbar.showSuccess(context, 'Ejercicio eliminado correctamente');
  }

  // ─── Selección masiva ───

  void _toggleSelectionMode(DifficultyLevel level) {
    setState(() {
      if (_selectionLevel == level) {
        _selectionLevel = null;
        _selectedIds.clear();
      } else {
        _selectionLevel = level;
        _selectedIds
          ..clear()
          ..addAll(_byLevel(level).where((e) => e.isActive).map((e) => e.id));
      }
    });
  }

  void _toggleSelected(String id) => setState(() {
        _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
      });

  void _selectAllInLevel() {
    if (_selectionLevel == null) return;
    setState(() => _selectedIds
      ..clear()
      ..addAll(_byLevel(_selectionLevel!).map((e) => e.id)));
  }

  Future<void> _applyMassiveVisibility({required bool isActive}) async {
    if (_selectedIds.isEmpty) return;
    await widget.repository.setExercisesActive(_selectedIds.toList(), isActive: isActive);
    setState(() {
      _selectionLevel = null;
      _selectedIds.clear();
    });
    _reload();
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        isActive ? 'Ejercicios activados correctamente' : 'Ejercicios desactivados correctamente',
      );
    }
  }

  void _exitSelectionMode() => setState(() {
        _selectionLevel = null;
        _selectedIds.clear();
      });

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [AppColors.primaryLight.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _PageHeader(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: LayoutBuilder(
                        builder: (_, constraints) => constraints.maxWidth > 900
                            ? _buildWideLayout()
                            : _buildNarrowLayout(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SelectionActionBar(
              visible: _selectionLevel != null,
              selectedCount: _selectedIds.length,
              totalCount: _selectionLevel == null ? 0 : _byLevel(_selectionLevel!).length,
              onActivate: () => _applyMassiveVisibility(isActive: true),
              onDeactivate: () => _applyMassiveVisibility(isActive: false),
              onSelectAll: _selectAllInLevel,
              onCancel: _exitSelectionMode,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Layouts ───

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildExercisesCard()),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 280,
          child: InfoPanel(
            exercises: _filteredExercises,
            isTeacher: widget.isTeacher,
            onCreateExercise: _onCreateExercise,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoPanel(
          exercises: _filteredExercises,
          isTeacher: widget.isTeacher,
          onCreateExercise: _onCreateExercise,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildExercisesCard(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildExercisesCard() {
    final filtered = _filteredExercises;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModuleHeaderCard(
            module: widget.module,
            selectedSubject: _subjectFilter,
            onSubjectChanged: (s) => setState(() => _subjectFilter = s),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (filtered.isEmpty)
            ExercisesEmptyState(onCreate: widget.isTeacher ? _onCreateExercise : null)
          else
            ..._buildSections(),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    for (final level in DifficultyLevel.values) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: AppSpacing.lg));
      widgets.add(
        DifficultySection(
          difficulty: level,
          exercises: _byLevel(level),
          isTeacher: widget.isTeacher,
          isSelectionMode: _selectionLevel == level,
          selectedIds: _selectionLevel == level ? _selectedIds : const {},
          onToggleSelectionMode: () => _toggleSelectionMode(level),
          onTapExercise: _onTapExercise,
          onDeleteExercise: _onDeleteExercise,
          // TODO(connect): implementar navegación a ExerciseFormPage en modo edición
          onEditExercise: (exercise) {},
          // TODO(connect): reemplazar por _onCreateExerciseForLevel(level)
          // cuando ExerciseFormPage soporte preselectedLevel
          onCreateExercise: _onCreateExercise,
        ),
      );
    }
    return widgets;
  }
}

// ─── Header de la página ───

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: HeaderDecorativeFigures()),
          Positioned(
            left: AppSpacing.md,
            top: 0,
            bottom: 0,
            child: Center(child: _BackButton(onTap: onBack)),
          ),
          Center(
            child: Text(
              'Creación y Edición de Ejercicios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón "← Volver" ───

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.3),
      borderRadius: const BorderRadius.all(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'Volver',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}