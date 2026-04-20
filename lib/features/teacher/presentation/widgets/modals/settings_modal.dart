import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/confirm_dialog.dart';
import '../../../../auth/presentation/auth_notifier.dart';
import '../../../../students/presentation/notifiers/students_notifier.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const SettingsModal());

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool _isLoading = false;

  Future<void> _deleteAllStudents(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar todos los estudiantes',
      content: '¿Estás seguro? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final studentsNotifier = context.read<StudentsNotifier>();
      final students = List.from(studentsNotifier.state.students);

      for (final student in students) {
        await studentsNotifier.deleteStudent(student.id ?? '');
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.showSuccess(context, 'Todos los estudiantes han sido eliminados');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Error al eliminar estudiantes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restartAll(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Reiniciar todo',
      content: 'Se eliminarán todos los estudiantes, contenidos y reportes. La cuenta del profesor se mantendrá. ¿Continuar?',
      confirmLabel: 'Reiniciar',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final studentsNotifier = context.read<StudentsNotifier>();
      final students = List.from(studentsNotifier.state.students);

      // Eliminar todos los estudiantes uno por uno
      for (final student in students) {
        await studentsNotifier.deleteStudent(student.id ?? '');
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.showSuccess(context, 'Todos los datos han sido reiniciados correctamente');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Error al reiniciar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Configuración',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionTitle(title: 'Datos'),
                const SizedBox(height: AppSpacing.md),
                _SettingButton(
                  icon: Icons.people_outline_rounded,
                  label: 'Eliminar todos los estudiantes',
                  onTap: _isLoading ? null : () => _deleteAllStudents(context),
                  isDestructive: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingButton(
                  icon: Icons.refresh_rounded,
                  label: 'Reiniciar todo',
                  subtitle: 'Eliminar todos los datos menos los del profesor',
                  onTap: _isLoading ? null : () => _restartAll(context),
                  isDestructive: true,
                ),

                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
  );
}

class _SettingButton extends StatelessWidget {
  const _SettingButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textHint,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              color: onTap == null ? AppColors.textHint : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
