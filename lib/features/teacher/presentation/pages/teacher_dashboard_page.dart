import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/auth_notifier.dart';
import '../../../../features/auth/presentation/pages/profile_page.dart';
import '../../../../features/modules/data/repositories/mock_module_repository.dart';
import '../../../../features/modules/domain/entities/module_entities.dart';
import '../../../../features/modules/presentation/pages/modules_page.dart';
import '../../../../features/reports/presentation/pages/reports_page.dart';
import '../../../../features/students/domain/entities/student_entity.dart';
import '../../../../features/students/presentation/notifiers/students_notifier.dart';
import '../../../../features/students/presentation/pages/student_form_page.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../widgets/dashboard/stats_overview_row.dart';
import '../widgets/layout/teacher_sidebar.dart';
import '../widgets/layout/teacher_topbar.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  int _selectedIndex = 0;
  final _moduleRepository = MockModuleRepository();

  Future<void> _onLogout() async {
    context.read<AuthNotifier>().logout();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  String get _teacherName => context.read<AuthNotifier>().state.userName ?? 'Profesor';

  String get _usuarioId => context.read<AuthNotifier>().state.userId ?? '';

  void _onChangePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Foto de Perfil'),
        content: const Text('Se abrirá la galería para seleccionar una nueva foto'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    usuarioId: _usuarioId,
                    nombreDocente: _teacherName,
                  ),
                ),
              );
            },
            child: const Text('Abrir Perfil'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    final studentsNotifier = context.read<StudentsNotifier>();

    return switch (index) {
      0 => _DashboardView(notifier: studentsNotifier),
      1 => ModulesPage(
          moduleType: ModuleType.reading,
          repository: _moduleRepository,
        ),
      2 => ModulesPage(
          moduleType: ModuleType.writing,
          repository: _moduleRepository,
        ),
      3 => const ReportsPage(),
      4 => const _ComingSoonView(label: 'Ajustes'),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TeacherSidebar(
            selectedIndex: _selectedIndex,
            teacherName: _teacherName,
            usuarioId: _usuarioId,
            onSelectIndex: (i) => setState(() => _selectedIndex = i),
            onLogout: _onLogout,
          ),
          Expanded(
            child: Column(
              children: [
                TeacherTopbar(
                  teacherName: _teacherName,
                  onChangePhoto: _onChangePhoto,
                  onLogout: _onLogout,
                ),
                Expanded(child: _buildContent(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.notifier});

  final StudentsNotifier notifier;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatsCard(child: StatsOverviewRow.mock()),
            const SizedBox(height: AppSpacing.lg),
            _StudentsCard(notifier: notifier),
          ],
        ),
      );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.child});

  final Widget child;

  static String get _title {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final now = DateTime.now();
    return 'Resumen de ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(AppRadius.xl),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0D9488),
              blurRadius: 40,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 90,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 200,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        stops: const [0.0, 0.35, 1.0],
                        colors: [
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsCard extends StatefulWidget {
  const _StudentsCard({required this.notifier});

  final StudentsNotifier notifier;

  @override
  State<_StudentsCard> createState() => _StudentsCardState();
}

class _StudentsCardState extends State<_StudentsCard> {
  final _searchCtrl = TextEditingController();
  int? _grade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.notifier.loadStudents());
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
    if (s.successMessage != null) {
      AppSnackbar.showSuccess(context, s.successMessage!);
      widget.notifier.clearMessage();
    }
    if (s.failure != null) {
      AppSnackbar.showError(context, s.failure!.message);
    }
    setState(() {});
  }

  void _search(String q) => widget.notifier.search(name: q, grade: _grade);

  void _filterGrade(int? g) {
    setState(() => _grade = g);
    widget.notifier.search(name: _searchCtrl.text, grade: g);
  }

  void _clear() {
    _searchCtrl.clear();
    setState(() => _grade = null);
    widget.notifier.clearFilters();
  }

  Future<void> _addStudent() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StudentFormPage(notifier: widget.notifier),
      ),
    );
    if (ok == true && mounted) {
      widget.notifier.loadStudents();
    }
  }

  Future<void> _editStudent(StudentEntity s) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StudentFormPage(
          notifier: widget.notifier,
          student: s,
        ),
      ),
    );
  }

  Future<void> _deleteStudent(StudentEntity s) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Eliminar estudiante',
      content:
          '¿Seguro que quieres eliminar a ${s.fullName}?\nEsta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok && mounted) {
      await widget.notifier.deleteStudent(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.notifier.state;
    final hasFilters = _searchCtrl.text.isNotEmpty || _grade != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre...',
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 25,
                            color: AppColors.border,
                          ),
                        ],
                      ),
                      suffixIcon: hasFilters
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: _clear,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        borderRadius:
                            const BorderRadius.all(AppRadius.medium),
                        color: AppColors.surfaceCard,
                      ),
                      child: DropdownButton<int?>(
                        value: _grade,
                        hint: const Text(
                          'Grado',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text('Todos'),
                            ),
                          ),
                          ...AppConstants.grades.map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text('$g° grado'),
                              ),
                            ),
                          ),
                        ],
                        onChanged: _filterGrade,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _addStudent,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Nuevo estudiante'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    minimumSize: const Size(0, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.medium),
                    ),
                  ).copyWith(
                    mouseCursor:
                        const WidgetStatePropertyAll(SystemMouseCursors.click),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: state.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              : state.isEmpty
                  ? _EmptyState(hasFilters: hasFilters, onAdd: _addStudent)
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _StudentGrid(
                        students: state.students,
                        onEdit: _editStudent,
                        onDelete: _deleteStudent,
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.10),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppColors.textSecondary),
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

class _StudentGrid extends StatelessWidget {
  const _StudentGrid({
    required this.students,
    required this.onEdit,
    required this.onDelete,
  });

  final List<StudentEntity> students;
  final ValueChanged<StudentEntity> onEdit;
  final ValueChanged<StudentEntity> onDelete;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          final cols = constraints.maxWidth > 900
              ? 4
              : constraints.maxWidth > 600
                  ? 3
                  : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
            ),
            itemCount: students.length,
            itemBuilder: (_, i) => _StudentCard(
              student: students[i],
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          );
        },
      );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

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
                    child: Center(
                      child: StudentAvatar(
                        initials: student.initials,
                        grade: student.grade,
                        radius: 36,
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        color: AppColors.surfaceCard,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.large),
                          side: BorderSide(color: AppColors.border),
                        ),
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: AppColors.textHint,
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            mouseCursor: SystemMouseCursors.click,
                            value: 'edit',
                            child: const Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            mouseCursor: SystemMouseCursors.click,
                            value: 'delete',
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
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
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      GradeBadge(
                        grade: student.grade,
                        size: GradeBadgeSize.small,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${student.age} años',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (student.conditions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...student.conditions.take(2).map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.10),
                              borderRadius:
                                  const BorderRadius.all(AppRadius.full),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        if (student.conditions.length > 2)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  const BorderRadius.all(AppRadius.full),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '+${student.conditions.length - 2}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
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
                child: Icon(
                  hasFilters
                      ? Icons.search_off_rounded
                      : Icons.people_outline_rounded,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                hasFilters
                    ? 'No se encontraron estudiantes'
                    : 'Aún no hay estudiantes',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                hasFilters
                    ? 'Intenta con otro nombre o grado'
                    : 'Agrega el primer estudiante para comenzar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (!hasFilters) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Agregar estudiante'),
                ),
              ],
            ],
          ),
        ),
      );
}
