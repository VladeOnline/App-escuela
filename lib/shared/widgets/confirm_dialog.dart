import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title, content: content,
        confirmLabel: confirmLabel, cancelLabel: cancelLabel,
        isDestructive: isDestructive, icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 90),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 52, height: 82,
                  decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(content, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxl),
              const Divider(height: 1, color: AppColors.border),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomLeft: AppRadius.xl),
                          ),
                        ),
                        child: Text(cancelLabel),
                      ),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: color,
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomRight: AppRadius.xl),
                          ),
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}