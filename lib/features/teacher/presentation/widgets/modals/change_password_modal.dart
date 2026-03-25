import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';

/// Modal para cambio de contraseña.
///
/// Valida localmente que los campos no estén vacíos y que las
/// contraseñas coincidan. Cuando el Back esté listo, reemplazar
/// el TODO en [_onSubmit] con la llamada al servicio real.
class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChangePasswordModal(),
    );
  }

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_currentController.text.trim().isEmpty) {
      return 'Ingresa tu contraseña actual.';
    }
    if (_newController.text.trim().length < 6) {
      return 'La nueva contraseña debe tener al menos 6 caracteres.';
    }
    if (_newController.text != _confirmController.text) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final error = _validate();
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO(back): reemplazar con AuthService.changePassword(...)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
    AppSnackbar.showSuccess(context, 'Contraseña actualizada correctamente');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModalHeader(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.lg),

              // Contraseña actual
              _PasswordField(
                controller: _currentController,
                label: 'Contraseña actual',
                showPassword: _showCurrent,
                onToggleVisibility: () =>
                    setState(() => _showCurrent = !_showCurrent),
              ),
              const SizedBox(height: AppSpacing.md),

              // Nueva contraseña
              _PasswordField(
                controller: _newController,
                label: 'Nueva contraseña',
                showPassword: _showNew,
                onToggleVisibility: () =>
                    setState(() => _showNew = !_showNew),
              ),
              const SizedBox(height: AppSpacing.md),

              // Confirmar contraseña
              _PasswordField(
                controller: _confirmController,
                label: 'Confirmar nueva contraseña',
                showPassword: _showConfirm,
                onToggleVisibility: () =>
                    setState(() => _showConfirm = !_showConfirm),
              ),

              // Mensaje de error
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Botón de acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Subwidgets privados ──────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(AppRadius.medium),
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Cambiar contraseña',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textHint,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.showPassword,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final bool showPassword;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: AppColors.textHint,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
