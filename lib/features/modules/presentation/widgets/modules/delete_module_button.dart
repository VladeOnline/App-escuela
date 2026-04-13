import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../data/repositories/api_module_repository.dart';

class DeleteModuleButton extends StatefulWidget {
  const DeleteModuleButton({
    super.key,
    required this.hovered,
    required this.moduleName,
    required this.moduleId,
    required this.repository,
    required this.onDeleted,
  });

  final bool hovered;
  final String moduleName;
  final String moduleId;
  final ApiModuleRepository repository;
  final VoidCallback onDeleted;

  @override
  State<DeleteModuleButton> createState() => _DeleteModuleButtonState();
}

class _DeleteModuleButtonState extends State<DeleteModuleButton> {
  bool _deleteHovered = false;

  Future<void> _showConfirmDialog(BuildContext context) async {
    final ctrl = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final confirmed = ctrl.text.trim() == widget.moduleName;
          bool isLoading = false;

          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.large)),
            backgroundColor: AppColors.surfaceCard,
            title: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded,
                    color: AppColors.error, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Eliminar módulo',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ]),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Advertencia ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                      border: Border.all(color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 16),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Esta acción es irreversible. Se eliminará el contenido permanentemente.',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                height: 1.45,
                                color: AppColors.error.withOpacity(0.85)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Instrucción ──────────────────────────────────────────
                  Text('Para confirmar, escribe el nombre del módulo:',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Nombre a confirmar ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(widget.moduleName,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Campo de texto ───────────────────────────────────────
                  TextFormField(
                    controller: ctrl,
                    autofocus: true,
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Escribe el nombre exacto...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.error, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary)),
              ),
              FilledButton(
                onPressed: confirmed && !isLoading
                    ? () async {
                        setDialogState(() => isLoading = true);

                        final failure = await widget.repository
                            .deleteModule(widget.moduleId);

                        if (!ctx.mounted) return;

                        Navigator.pop(ctx);

                        if (failure != null) {
                          AppSnackbar.showError(context, failure.message);
                        } else {
                          AppSnackbar.showSuccess(
                              context, 'Contenido eliminado correctamente');
                          widget.onDeleted();
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.error.withOpacity(0.3),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.medium)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Eliminar',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );

    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: widget.hovered ? 1.0 : 0.0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _deleteHovered = true),
        onExit:  (_) => setState(() => _deleteHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showConfirmDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _deleteHovered
                  ? AppColors.error
                  : AppColors.error.withOpacity(0.1),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              boxShadow: _deleteHovered
                  ? [BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 8)]
                  : [],
            ),
            child: Icon(Icons.delete_outline_rounded,
                size: 18,
                color: _deleteHovered ? Colors.white : AppColors.error),
          ),
        ),
      ),
    );
  }
}