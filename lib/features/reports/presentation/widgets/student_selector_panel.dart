import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/students/domain/entities/student_entity.dart';
import '../../../../../shared/widgets/grade_badge.dart';

/// Panel izquierdo con buscador y lista de estudiantes.
/// Se separa en sub-widgets para mantener cada clase por debajo de ~100 líneas.
class StudentSelectorPanel extends StatefulWidget {
  const StudentSelectorPanel({
    super.key,
    required this.students,
    required this.selectedStudent,
    required this.onChanged,
  });

  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final ValueChanged<StudentEntity> onChanged;

  @override
  State<StudentSelectorPanel> createState() => _StudentSelectorPanelState();
}

class _StudentSelectorPanelState extends State<StudentSelectorPanel> {
  final _searchController = TextEditingController();
  List<StudentEntity> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.students;
  }

  @override
  void didUpdateWidget(StudentSelectorPanel old) {
    super.didUpdateWidget(old);
    if (old.students != widget.students) {
      _applyFilter(_searchController.text);
    }
  }

  void _applyFilter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.students
          : widget.students
              .where((s) => s.fullName.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
          ),
          child: Text(
            'SELECCIONAR ESTUDIANTE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
        ),

        // ── Buscador ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: _SearchField(
            controller: _searchController,
            onChanged: _applyFilter,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Lista ────────────────────────────────────────────────
        if (_filtered.isEmpty)
          _EmptySearch()
        else
          _StudentList(
            students: _filtered,
            selected: widget.selectedStudent,
            onTap: widget.onChanged,
          ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        hintText: 'Buscar estudiante...',
        prefixIcon: Icon(Icons.search_rounded, size: 18),
      ),
    );
  }
}

class _StudentList extends StatelessWidget {
  const _StudentList({
    required this.students,
    required this.selected,
    required this.onTap,
  });

  final List<StudentEntity> students;
  final StudentEntity? selected;
  final ValueChanged<StudentEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: students.length,
      itemBuilder: (context, i) => _StudentRow(
        student: students[i],
        isSelected: students[i] == selected,
        onTap: () => onTap(students[i]),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.isSelected,
    required this.onTap,
  });

  final StudentEntity student;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadius.medium),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.medium),
        ),
        child: Row(
          children: [
            StudentAvatar(
              initials: student.initials,
              grade: student.grade,
              radius: 18,
              photoUrl: student.photoUrl,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  GradeBadge(grade: student.grade, size: GradeBadgeSize.small),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text(
          'No se encontraron estudiantes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
        ),
      ),
    );
  }
}
