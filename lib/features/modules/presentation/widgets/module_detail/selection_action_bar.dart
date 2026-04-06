import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Barra inferior animada que aparece cuando una sección entra en modo
/// selección masiva. Muestra el conteo de seleccionados y los botones
/// para activar/desactivar y seleccionar todos.
class SelectionActionBar extends StatelessWidget {
  const SelectionActionBar({
    super.key,
    required this.visible,
    required this.selectedCount,
    required this.totalCount,
    required this.onActivate,
    required this.onDeactivate,
    required this.onSelectAll,
    required this.onCancel,
  });

  final bool visible;
  final int selectedCount;
  final int totalCount;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onSelectAll;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: const BorderRadius.all(AppRadius.large),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: 'Salir del modo selección',
              ),
              Text(
                '$selectedCount / $totalCount seleccionados',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSelectAll,
                icon: const Icon(Icons.select_all_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Todos',
                  style: TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                ),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: selectedCount > 0 ? onDeactivate : null,
                icon: const Icon(Icons.visibility_off_rounded, size: 16),
                label: const Text('Desactivar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: selectedCount > 0 ? onActivate : null,
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Activar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
