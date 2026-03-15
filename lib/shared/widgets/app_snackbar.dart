import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Helper centralizado para mostrar notificaciones visuales.
/// Todas las notificaciones de la app pasan por aquí para garantizar
/// consistencia visual y poder cambiarlas en un solo lugar.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.success,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.error,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppColors.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppColors.info,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
