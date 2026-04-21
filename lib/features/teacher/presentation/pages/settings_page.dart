import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/auth_notifier.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  Future<void> _deleteAllStudents() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Borrar todos los estudiantes',
      content: '¿Estás seguro de que deseas borrar TODOS los estudiantes? Esta acción no se puede deshacer.',
      confirmLabel: 'Borrar todo',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthNotifier>().state.token ?? '';
      
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/admin/delete-all-students'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        AppSnackbar.showSuccess(
          context,
          'Todos los estudiantes han sido borrados',
        );
      } else {
        AppSnackbar.showError(
          context,
          'Error al borrar estudiantes: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Error: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetSystem() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Reiniciar sistema',
      content: 'Esto borrará TODOS los estudiantes, evaluaciones y datos, pero mantiene tu información como docente. ¿Continuar?',
      confirmLabel: 'Reiniciar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthNotifier>().state.token ?? '';
      
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/admin/reset-system'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        AppSnackbar.showSuccess(
          context,
          'Sistema reiniciado. Tu información se mantiene.',
        );
      } else {
        AppSnackbar.showError(
          context,
          'Error al reiniciar: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Error: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajustes y administración',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gestiona tu clase y datos del sistema',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Sección: Administración de datos
          _SectionCard(
            title: 'Administración de datos',
            children: [
              _SettingButton(
                icon: Icons.person_remove_rounded,
                title: 'Borrar todos los estudiantes',
                subtitle: 'Elimina todos los estudiantes pero mantiene tu cuenta',
                isDangerous: true,
                isLoading: _isLoading,
                onPressed: _deleteAllStudents,
              ),
              const SizedBox(height: AppSpacing.md),
              _SettingButton(
                icon: Icons.restart_alt_rounded,
                title: 'Reiniciar sistema',
                subtitle: 'Borra todo: estudiantes, evaluaciones, resultados. Tu cuenta se mantiene.',
                isDangerous: true,
                isLoading: _isLoading,
                onPressed: _resetSystem,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Sección: Información
          _SectionCard(
            title: 'Información del sistema',
            children: [
              _InfoRow(
                label: 'Versión de API',
                value: 'v1.0',
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: 'Servidor',
                value: AppConstants.apiBaseUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.border),
            borderRadius: const BorderRadius.all(AppRadius.large),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDangerous,
    required this.isLoading,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDangerous;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isDangerous ? AppColors.error : AppColors.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                          ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
