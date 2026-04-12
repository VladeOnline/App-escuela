import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

// ─── Header (solo título) ───

class ExFormHeader extends StatelessWidget {
  const ExFormHeader({
    super.key,
    required this.moduleTitle,
    this.isEditing = false,
  });

  final String moduleTitle;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final prefix = isEditing ? 'Edición de ejercicio' : 'Nuevo ejercicio';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.92),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          '$prefix — $moduleTitle',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Botón volver (pill) ───

class ExFormBackButton extends StatelessWidget {
  const ExFormBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.all(AppRadius.full),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text('Volver', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer fijo ───

class ExFormFooter extends StatelessWidget {
  const ExFormFooter({
    super.key,
    required this.isLoading,
    required this.onClear,
    required this.onSave,
    this.isEditing = false,
  });

  final bool isLoading;
  final bool isEditing;
  final VoidCallback onClear;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: AppColors.border.withOpacity(0.8)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          color: AppColors.surfaceCard.withOpacity(0.95),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, color: AppColors.textHint),
                  children: const [
                    TextSpan(text: 'Todos los campos con '),
                    TextSpan(text: '*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                    TextSpan(text: ' son obligatorios'),
                  ],
                ),
              ),
              const Spacer(),
              Container(width: 1, height: 28, color: AppColors.border),
              const SizedBox(width: AppSpacing.md),
              if (!isEditing) ...[
                OutlinedButton(
                  onPressed: isLoading ? null : onClear,
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)),
                    minimumSize: const Size(0, 44),
                  ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              FilledButton.icon(
                onPressed: isLoading ? null : onSave,
                icon: isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEditing ? Icons.check_rounded : Icons.save_rounded, size: 18),
                label: Text(isEditing ? 'Guardar cambios' : 'Guardar ejercicio'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 44),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)),
                ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(width: 1, height: 28, color: AppColors.border),
            ],
          ),
        ),
      ],
    );
  }
}
