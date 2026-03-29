import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../../domain/entities/student_entity.dart';
import '../notifiers/students_notifier.dart';
import 'student_form_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key, required this.notifier});
  final StudentsNotifier notifier;
  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final _searchCtrl = TextEditingController();
  int? _grade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.notifier.loadStudents());
    widget.notifier.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    widget.notifier.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    final s = widget.notifier.state;
    if (s.successMessage != null) { AppSnackbar.showSuccess(context, s.successMessage!); widget.notifier.clearMessage(); }
    if (s.failure != null) AppSnackbar.showError(context, s.failure!.message);
    setState(() {});
  }

  void _search(String q) => widget.notifier.search(name: q, grade: _grade);

  void _filterGrade(int? g) {
    setState(() => _grade = g);
    widget.notifier.search(name: _searchCtrl.text, grade: g);
  }

  Future<void> _addStudent() async {
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => StudentFormPage(notifier: widget.notifier)));
    if (ok == true && mounted) widget.notifier.loadStudents();
  }

  Future<void> _editStudent(StudentEntity s) async =>
    Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => StudentFormPage(notifier: widget.notifier, student: s)));

  Future<void> _deleteStudent(StudentEntity s) async {
    final ok = await ConfirmDialog.show(context,
      title: 'Eliminar estudiante',
      content: '¿Seguro que quieres eliminar a ${s.fullName}?\nEsta acción no se puede deshacer.',
      confirmLabel: 'Eliminar', cancelLabel: 'Cancelar',
      isDestructive: true, icon: Icons.delete_outline_rounded,
    );
    if (ok && mounted) await widget.notifier.deleteStudent(s.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.notifier.state;
    final hasFilters = _searchCtrl.text.isNotEmpty || _grade != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Estudiantes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: _addStudent,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Nuevo estudiante'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            selectedGrade: _grade,
            onSearch: _search,
            onGradeFilter: _filterGrade,
            onClear: () { _searchCtrl.clear(); setState(() => _grade = null); widget.notifier.clearFilters(); },
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : state.isEmpty
                    ? _EmptyState(hasFilters: hasFilters, onAdd: _addStudent)
                    : _StudentGrid(students: state.students, onEdit: _editStudent, onDelete: _deleteStudent),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.selectedGrade, required this.onSearch, required this.onGradeFilter, required this.onClear});
  final TextEditingController controller;
  final int? selectedGrade;
  final ValueChanged<String> onSearch;
  final ValueChanged<int?> onGradeFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceCard,
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: controller.text.isNotEmpty || selectedGrade != null
                  ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: onClear)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _GradeChip(label: 'Todos', isSelected: selectedGrade == null, onTap: () => onGradeFilter(null)),
                const SizedBox(width: AppSpacing.sm),
                ...AppConstants.grades.map((g) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _GradeChip(label: '$g°', color: AppColors.forGrade(g), isSelected: selectedGrade == g, onTap: () => onGradeFilter(g)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.label, required this.isSelected, required this.onTap, this.color});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.12) : Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.full),
          border: Border.all(color: isSelected ? c : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? c : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13, fontFamily: 'Nunito')),
      ),
    );
  }
}

class _StudentGrid extends StatelessWidget {
  const _StudentGrid({required this.students, required this.onEdit, required this.onDelete});
  final List<StudentEntity> students;
  final ValueChanged<StudentEntity> onEdit;
  final ValueChanged<StudentEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(builder: (_, constraints) {
        final cols = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols, crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md, childAspectRatio: 0.85,
          ),
          itemCount: students.length,
          itemBuilder: (_, i) => _StudentCard(student: students[i], onEdit: onEdit, onDelete: onDelete),
        );
      }),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onEdit, required this.onDelete});
  final StudentEntity student;
  final ValueChanged<StudentEntity> onEdit;
  final ValueChanged<StudentEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppColors.forGrade(student.grade);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onEdit(student),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: const BorderRadius.all(AppRadius.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: gradeColor.withOpacity(0.07),
                    child: Center(child: StudentAvatar(initials: student.initials, grade: student.grade, radius: 36)),
                  ),
                  // TODO(back): reemplazar StudentAvatar con Image.network(student.photoUrl)
                  Positioned(
                    top: AppSpacing.xs, right: AppSpacing.xs,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        color: AppColors.surfaceCard,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large), side: BorderSide(color: AppColors.border)),
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textHint),
                        itemBuilder: (_) => [
                          PopupMenuItem(mouseCursor: SystemMouseCursors.click, value: 'edit', child: const Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Editar')])),
                          PopupMenuItem(mouseCursor: SystemMouseCursors.click, value: 'delete', child: const Row(children: [Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppColors.error))])),
                        ],
                        onSelected: (action) {
                          if (action == 'edit') onEdit(student);
                          if (action == 'delete') onDelete(student);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    GradeBadge(grade: student.grade, size: GradeBadgeSize.small),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${student.age} años', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onAdd});
  final bool hasFilters;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(hasFilters ? Icons.search_off_rounded : Icons.people_outline_rounded, size: 40, color: AppColors.primary.withOpacity(0.5))),
        const SizedBox(height: AppSpacing.md),
        Text(hasFilters ? 'No se encontraron estudiantes' : 'Aún no hay estudiantes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Text(hasFilters ? 'Intenta con otro nombre o grado' : 'Agrega el primer estudiante para comenzar',
            style: Theme.of(context).textTheme.bodyMedium),
        if (!hasFilters) ...[
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.person_add_alt_1_rounded, size: 18), label: const Text('Agregar estudiante')),
        ],
      ],
    ),
  );
}
