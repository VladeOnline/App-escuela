import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

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

  static const _btnShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(AppRadius.small),
  );

  static const _btnPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static const _btnTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    fontFamily: 'Nunito',
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(AppRadius.large),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // ── Botón cerrar ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(AppRadius.small),
                  ),
                  child: IconButton(
                    onPressed: onCancel,
                    mouseCursor: SystemMouseCursors.click,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Salir del modo selección',
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // ── Contador ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Modo Selección',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$selectedCount de $totalCount seleccionados',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // ── Botón "Todos" ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(AppRadius.small),
                  ),
                  child: TextButton.icon(
                    onPressed: onSelectAll,
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Todos',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: _btnShape,
                    ).copyWith(
                      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ── Botón "Ocultar" ──
                FilledButton.icon(
                  onPressed: selectedCount > 0 ? onDeactivate : null,
                  icon: const Icon(Icons.visibility_off_rounded, size: 16),
                  label: const Text('Ocultar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.error.withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                    padding: _btnPadding,
                    elevation: 4,
                    shadowColor: AppColors.error.withOpacity(0.2),
                    shape: _btnShape,
                    textStyle: _btnTextStyle,
                  ).copyWith(
                    mouseCursor: WidgetStateProperty.resolveWith((states) =>
                        states.contains(WidgetState.disabled)
                            ? SystemMouseCursors.forbidden
                            : SystemMouseCursors.click),
                  ),
                ),
                const SizedBox(width: 8),

                // ── Botón "Mostrar" ──
                FilledButton.icon(
                  onPressed: selectedCount > 0 ? onActivate : null,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Mostrar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    disabledForegroundColor: AppColors.primary.withOpacity(0.5),
                    padding: _btnPadding,
                    elevation: 4,
                    shadowColor: Colors.white.withOpacity(0.4),
                    shape: _btnShape,
                    textStyle: _btnTextStyle,
                  ).copyWith(
                    mouseCursor: WidgetStateProperty.resolveWith((states) =>
                        states.contains(WidgetState.disabled)
                            ? SystemMouseCursors.forbidden
                            : SystemMouseCursors.click),
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