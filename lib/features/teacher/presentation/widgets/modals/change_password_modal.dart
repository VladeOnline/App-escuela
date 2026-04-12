import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  static void show(BuildContext context) =>
      showDialog(context: context, builder: (_) => const ChangePasswordModal());

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  bool _isLoading = false;

  _Field? _errorField;
  String? _errorMessage;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _newCtrl.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s++;
    return s;
  }

  static const _strengthLabels = ['', 'Débil', 'Regular', 'Buena', 'Fuerte'];
  static const _strengthColors = [
    Colors.transparent,
    AppColors.error,
    AppColors.warning,
    AppColors.secondaryLight,
    AppColors.success,
  ];

  void _setError(_Field field, String message) =>
      setState(() { _errorField = field; _errorMessage = message; });

  void _clearError() =>
      setState(() { _errorField = null; _errorMessage = null; });

  Future<void> _onSubmit() async {
    if (_currentCtrl.text.trim().isEmpty) {
      _setError(_Field.current, 'Ingresa tu contraseña actual');
      return;
    }
    if (_newCtrl.text.trim().length < 6) {
      _setError(_Field.newPass, 'Mínimo 6 caracteres');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      _setError(_Field.confirm, 'Las contraseñas no coinciden');
      return;
    }
    _clearError();
    setState(() => _isLoading = true);
    // TODO(back): AuthService.changePassword(_currentCtrl.text, _newCtrl.text)
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
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onClose: () => Navigator.of(context).pop(),
                errorMessage: _errorMessage,
              ),
              const SizedBox(height: AppSpacing.xl),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PasswordField(
                            controller: _currentCtrl,
                            label: 'Contraseña actual',
                            show: _showCurrent,
                            hasError: _errorField == _Field.current,
                            onToggle: () => setState(() => _showCurrent = !_showCurrent),
                            onChanged: (_) => _clearError(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _PasswordField(
                            controller: _newCtrl,
                            label: 'Nueva contraseña',
                            show: _showNew,
                            hasError: _errorField == _Field.newPass,
                            onToggle: () => setState(() => _showNew = !_showNew),
                            onChanged: (_) { _clearError(); setState(() {}); },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_newCtrl.text.isNotEmpty)
                            _StrengthBar(
                              strength: _strength,
                              label: _strengthLabels[_strength],
                              color: _strengthColors[_strength],
                            ),
                          const SizedBox(height: AppSpacing.md),
                          _PasswordField(
                            controller: _confirmCtrl,
                            label: 'Confirmar contraseña',
                            show: _showConfirm,
                            hasError: _errorField == _Field.confirm,
                            onToggle: () => setState(() => _showConfirm = !_showConfirm),
                            onChanged: (_) => _clearError(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    const Expanded(flex: 2, child: _SecurityTips()),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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

enum _Field { current, newPass, confirm }

// --- Subwidgets ---

class _Header extends StatelessWidget {
  const _Header({required this.onClose, this.errorMessage});
  final VoidCallback onClose;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.all(AppRadius.medium),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cambiar contraseña', style: Theme.of(context).textTheme.headlineMedium),
                  Text('Actualiza tu contraseña de acceso.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            if (errorMessage == null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
              ),
          ],
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.show,
    required this.onToggle,
    this.hasError = false,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final bool show;
  final bool hasError;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: !show,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: hasError ? AppColors.error : null,
          ),
          labelStyle: hasError ? const TextStyle(color: AppColors.error) : null,
          enabledBorder: hasError ? const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.medium),
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
          ) : null,
          focusedBorder: hasError ? const OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.medium),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ) : null,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: IconButton(
              icon: Icon(
                show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18,
                color: AppColors.textHint,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      );
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength, required this.label, required this.color});
  final int strength;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength ? color : AppColors.border,
                  borderRadius: const BorderRadius.all(AppRadius.full),
                ),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
        ],
      );
}

class _SecurityTips extends StatelessWidget {
  const _SecurityTips();

  static const _tips = [
    'Usa al menos 8 caracteres',
    'Combina mayúsculas y minúsculas',
    'Incluye números y símbolos',
    'Evita información personal',
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consejos de seguridad', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ..._tips.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: Text(t, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ),
      );
}

