import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

// TODO(back): reemplazar _videoUrl con la URL real del video tutorial.
class HelpModal extends StatelessWidget {
  const HelpModal({super.key});

  static void show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const HelpModal());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.md),
              const _VideoPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.md),
              const _KeyPoints(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.all(AppRadius.medium),
            ),
            child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Cómo funciona el sistema?', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  'Este video te guía por las funciones principales del sistema.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
          ),
        ],
      );
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.all(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.play_circle_filled_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Video tutorial', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
            Text('Disponible próximamente', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      );
}

class _KeyPoints extends StatelessWidget {
  const _KeyPoints();

  static const _points = [
    (time: '0:00', label: 'Inicio - presentación del sistema'),
    (time: '1:00', label: 'Materias y módulos disponibles'),
    (time: '2:30', label: 'Gestión de estudiantes'),
    (time: '4:00', label: 'Reportes y progreso'),
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Puntos del video', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ..._points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.10), borderRadius: const BorderRadius.all(AppRadius.full)),
                      child: Text(p.time, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(p.label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
        ],
      );
}

