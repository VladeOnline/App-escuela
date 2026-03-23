import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../auth_notifier.dart';
import '../widgets/animated_login_background.dart';
import '../widgets/login_credentials_card.dart';
import '../widgets/login_left_panel.dart';
import '../widgets/login_role_selector_card.dart';

/// Pantalla de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Animación de entrada inicial
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Animación de transición entre pasos
  late final AnimationController _stepCtrl;
  late final Animation<Offset> _stepSlide;
  late final Animation<double> _stepFade;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showCredentials = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _stepSlide = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _stepCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
      _showCredentials = true;
    });
    _stepCtrl.forward(from: 0);
  }

  void _onBack() {
    _stepCtrl.reverse().then((_) {
      setState(() {
        _showCredentials = false;
        _selectedRole = null;
        _usernameController.clear();
        _passwordController.clear();
      });
    });
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthNotifier>();
   final success = await auth.login(
  username: _usernameController.text,
  password: _passwordController.text,
  role: _selectedRole ?? AppConstants.roleTeacher,
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
      body: Stack(
        children: [
          const AnimatedLoginBackground(),
          Row(
            children: [
              const LoginLeftPanel(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: FadeTransition(
                      opacity: _entryFade,
                      child: SlideTransition(
                        position: _entrySlide,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _showCredentials ? 420 : 580,
                          ),
                          child: _showCredentials
                              ? _buildCredentials()
                              : _buildRoleSelector(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() => LoginRoleSelectorCard(onRoleSelected: _onRoleSelected);

  Widget _buildCredentials() => FadeTransition(
    opacity: _stepFade,
    child: SlideTransition(
      position: _stepSlide,
      child: LoginCredentialsCard(
        formKey: _formKey,
        role: _selectedRole!,
        usernameController: _usernameController,
        passwordController: _passwordController,
        obscurePassword: _obscurePassword,
        isLoading: _isLoading,
        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
        onLogin: _onLogin,
        onBack: _onBack,
      ),
    ),
  );
}