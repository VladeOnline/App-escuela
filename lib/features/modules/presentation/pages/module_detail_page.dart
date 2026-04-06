import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/confirm_dialog.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/module_detail/difficulty_section.dart';
import '../widgets/module_detail/exercises_empty_state.dart';
import '../widgets/module_detail/info_panel.dart';
import '../widgets/module_detail/module_header_card.dart';
import '../widgets/module_detail/selection_action_bar.dart';
import 'exercise_detail_page.dart';
import 'exercise_form_page.dart';

/// Página de detalle de un módulo. Muestra los ejercicios agrupados por
/// nivel de dificultad, con filtro por materia, panel de info y modo de
/// selección masiva por sección (RF-09, RF-11, RF-12).
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

  /// Qué nivel está actualmente en modo selección masiva. `null` = ninguno.
  DifficultyLevel? _selectionLevel;
  final Set<String> _selectedIds = {};

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _exercises = widget.repository.getExercisesByModule(widget.module.id);
    });
  }

  // ─── Getters derivados ──────────────────────────────────────────────────────

  List<ExerciseEntity> get _filteredExercises {
    if (_subjectFilter == null) return _exercises;
    return _exercises.where((e) => e.subject == _subjectFilter).toList();
  }

  List<ExerciseEntity> _byLevel(DifficultyLevel d) =>
      _filteredExercises.where((e) => e.difficulty == d).toList();

  // ─── Acciones de ejercicios ─────────────────────────────────────────────────

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
      content:
          '¿Seguro que quieres eliminar "${exercise.title}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await widget.repository.deleteExercise(exercise.id);
    _reload();
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Ejercicio eliminado correctamente');
    }
  }

  // ─── Selección masiva ───────────────────────────────────────────────────────

  void _toggleSelectionMode(DifficultyLevel level) {
    setState(() {
      if (_selectionLevel == level) {
        _selectionLevel = null;
        _selectedIds.clear();
      } else {
        _selectionLevel = level;
        // Por defecto marcamos todos los activos del nivel.
        _selectedIds
          ..clear()
          ..addAll(_byLevel(level).where((e) => e.isActive).map((e) => e.id));
      }
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAllInLevel() {
    if (_selectionLevel == null) return;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_byLevel(_selectionLevel!).map((e) => e.id));
    });
  }

  Future<void> _applyMassiveVisibility({required bool isActive}) async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();
    await widget.repository.setExercisesActive(ids, isActive: isActive);
    setState(() {
      _selectionLevel = null;
      _selectedIds.clear();
    });
    _reload();
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        isActive
            ? 'Ejercicios activados correctamente'
            : 'Ejercicios desactivados correctamente',
      );
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionLevel = null;
      _selectedIds.clear();
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
        ),
        title: const Text('Creación y Edición de Ejercicios'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return isWide ? _buildWideLayout() : _buildNarrowLayout();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SelectionActionBar(
              visible: _selectionLevel != null,
              selectedCount: _selectedIds.length,
              totalCount:
                  _selectionLevel == null ? 0 : _byLevel(_selectionLevel!).length,
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

  // ─── Layouts ────────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildExercisesCard()),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 240,
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

  // ─── Card grande de ejercicios ──────────────────────────────────────────────

  Widget _buildExercisesCard() {
    final filtered = _filteredExercises;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
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
            ExercisesEmptyState(
              onCreate: widget.isTeacher ? _onCreateExercise : null,
            )
          else
            ..._buildSections(),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    for (final level in DifficultyLevel.values) {
      final items = _byLevel(level);
      if (items.isEmpty) continue;
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.lg));
      }
      widgets.add(
        DifficultySection(
          difficulty: level,
          exercises: items,
          isTeacher: widget.isTeacher,
          isSelectionMode: _selectionLevel == level,
          selectedIds: _selectionLevel == level ? _selectedIds : const {},
          onToggleSelectionMode: () => _toggleSelectionMode(level),
          onTapExercise: _onTapExercise,
          onDeleteExercise: _onDeleteExercise,
        ),
      );
    }
    return widgets;
  }
}
