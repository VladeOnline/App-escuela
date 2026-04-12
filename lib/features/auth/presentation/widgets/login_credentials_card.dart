import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LoginCredentialsCard extends StatelessWidget {
  const LoginCredentialsCard({
    super.key,
    required this.formKey,
    required this.role,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onBack,
  });

  final GlobalKey<FormState> formKey;
  final String role;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure, onLogin, onBack;

  bool get _isTeacher => role == AppConstants.roleTeacher;
  String get _imagePath => _isTeacher
      ? 'assets/images/buho_profesor.png'
      : 'assets/images/buho_alumno.png';

  @override
  Widget build(BuildContext context) {
    const owlRadius = 64.0;
    const owlOverlap = 44.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: owlRadius - owlOverlap),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 60, spreadRadius: -4, offset: const Offset(0, 20)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24, offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(AppRadius.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CredentialsHeader(onBack: onBack),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: Text(
                            _isTeacher ? '¡Bienvenido, profesor!' : '¡Bienvenido, alumno!',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                              fontFamily: 'Nunito', color: AppColors.textPrimary),
                          )),
                          const SizedBox(height: AppSpacing.lg),
                          const _Divider(),
                          const SizedBox(height: AppSpacing.lg),
                          _UsernameField(controller: usernameController),
                          const SizedBox(height: AppSpacing.md),
                          _PasswordField(
                            controller: passwordController,
                            obscure: obscurePassword,
                            onToggle: onToggleObscure,
                            onSubmit: onLogin,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _LoginButton(isLoading: isLoading, onLogin: onLogin),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: owlRadius * 2, height: owlRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 3),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: ClipOval(
              child: Image.asset(_imagePath, fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
                errorBuilder: (_, __, ___) => Icon(
                  _isTeacher ? Icons.person_rounded : Icons.face_rounded,
                  color: AppColors.primary, size: 52),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Header ---

class _CredentialsHeader extends StatelessWidget {
  const _CredentialsHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.xl, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Derecha
          _circle(top: -20, right: -30, size: 100, opacity: 0.07),
          _circleBorder(bottom: -10, right: 30, size: 48, opacity: 0.15),
          _circle(top: 8, right: 80, size: 20, opacity: 0.10),
          // Izquierda
          _circle(top: -18, left: -28, size: 85, opacity: 0.06),
          _circleBorder(bottom: -8, left: 32, size: 36, opacity: 0.12),
          // Flecha
          Align(
            alignment: Alignment.centerLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({double? top, double? bottom, double? left, double? right,
    required double size, required double opacity}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity))),
    );
  }

  Widget _circleBorder({double? top, double? bottom, double? left, double? right,
    required double size, required double opacity}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: opacity), width: 1.5),
          color: Colors.transparent)),
    );
  }
}

// --- Divisor ---

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _line([Colors.transparent, AppColors.primary.withValues(alpha: 0.25)]),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(4, 0.2), const SizedBox(width: 4),
          _dot(6, 0.4), const SizedBox(width: 4),
          _dot(4, 0.2),
        ]),
      ),
      _line([AppColors.primary.withValues(alpha: 0.25), Colors.transparent]),
    ]);
  }

  Widget _line(List<Color> colors) => Expanded(
    child: Container(height: 1,
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors))),
  );

  Widget _dot(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
      color: AppColors.primary.withValues(alpha: opacity)),
  );
}

// --- Campos ---

class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.next,
    decoration: const InputDecoration(
      labelText: 'Usuario', hintText: 'Ej: Juan Pérez',
      prefixIcon: Icon(Icons.person_outline_rounded),
    ),
    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.obscure,
    required this.onToggle, required this.onSubmit});
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle, onSubmit;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    textInputAction: TextInputAction.done,
    onFieldSubmitted: (_) => onSubmit(),
    decoration: InputDecoration(
      labelText: 'Contraseña',
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ),
      ),
    ),
    validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
  );
}

// --- Botón ---

class _LoginButton extends StatefulWidget {
  const _LoginButton({required this.isLoading, required this.onLogin});
  final bool isLoading;
  final VoidCallback onLogin;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: widget.isLoading ? null : widget.onLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          color: _hovered ? AppColors.primary.withValues(alpha: 0.85) : AppColors.primary,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(child: widget.isLoading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito', color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
        ),
      ),
    ),
  );
}

