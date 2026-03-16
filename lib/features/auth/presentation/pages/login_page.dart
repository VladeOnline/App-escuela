import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../auth_notifier.dart';

/// Pantalla de inicio de sesión — RF-05
/// Autenticación por roles: docente / estudiante.
/// La lógica de auth está lista para conectarse con el Back.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = AppConstants.roleTeacher;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthNotifier>();
    final success = await auth.login(
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final route = _selectedRole == AppConstants.roleTeacher
          ? AppRoutes.teacherHome
          : AppRoutes.studentHome;
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      final failure = auth.state.failure;
      if (failure != null) {
        AppSnackbar.showError(context, failure.message);
        auth.clearFailure();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          _LeftPanel(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _LoginForm(
                        formKey: _formKey,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        isLoading: _isLoading,
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) =>
                            setState(() => _selectedRole = role),
                        onToggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        onLogin: _onLogin,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel izquierdo decorativo ───────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos de fondo
          Positioned(
            top: -60,
            left: -60,
            child: _DecorativeCircle(size: 200, opacity: 0.08),
          ),
          Positioned(
            bottom: 80,
            right: -80,
            child: _DecorativeCircle(size: 280, opacity: 0.06),
          ),
          Positioned(
            top: 200,
            right: 20,
            child: _DecorativeCircle(size: 100, opacity: 0.1),
          ),
          // Contenido central
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono de app
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: const BorderRadius.all(AppRadius.large),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Refuerzo\nEscolar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Herramienta de apoyo para docentes\ny estudiantes de escuela primaria.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Íconos de características
                ...[
                  (Icons.people_alt_rounded, 'Gestión de estudiantes'),
                  (Icons.menu_book_rounded, 'Contenido por grado'),
                  (Icons.emoji_events_rounded, 'Gamificación educativa'),
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.$1, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

// ─── Formulario de login ──────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onToggleObscure,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bienvenido 👋',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Selecciona tu rol e ingresa tu contraseña',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Selector de rol (RF-05)
          _RoleSelector(
            selectedRole: selectedRole,
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Campo contraseña
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onLogin(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              if (value.length < 3) {
                return 'La contraseña es demasiado corta';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Botón de ingreso
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Ingresar'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Hint de credenciales mock (solo en desarrollo)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Modo desarrollo — Contraseña: ${AppConstants.mockTeacherPassword}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selector de rol ──────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleTile(
            role: AppConstants.roleTeacher,
            label: 'Docente',
            icon: Icons.person_rounded,
            isSelected: selectedRole == AppConstants.roleTeacher,
            onTap: () => onChanged(AppConstants.roleTeacher),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _RoleTile(
            role: AppConstants.roleStudent,
            label: 'Estudiante',
            icon: Icons.face_rounded,
            isSelected: selectedRole == AppConstants.roleStudent,
            onTap: () => onChanged(AppConstants.roleStudent),
          ),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String role;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
