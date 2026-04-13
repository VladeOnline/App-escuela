import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../modules/data/repositories/api_module_repository.dart';
import '../../../modules/domain/entities/module_entities.dart';
import '../../../modules/presentation/pages/module_detail_page.dart';

// StudentHomePage
// TODO(back): obtener grado, nombre y puntos del estudiante autenticado
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late ApiModuleRepository _repository;
  List<ModuleEntity> _modules = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthNotifier>().state.token ?? '';
    _repository = ApiModuleRepository(token: token);
    _loadModules(showLoader: true);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _loadModules();
    });
  }

  Future<void> _loadModules({bool showLoader = false}) async {
    if (_isReloading) return;
    _isReloading = true;
    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final authState = context.read<AuthNotifier>().state;
      final grade = authState.studentGrade ?? 1;
      final studentId = authState.studentId;
      final reading = await _repository.getModulesByType(ModuleType.reading);
      final writing = await _repository.getModulesByType(ModuleType.writing);
      final math = await _repository.getModulesByType(ModuleType.math);
      final byGrade = <ModuleEntity>[
        ...reading.modules.where((m) => m.grade == grade),
        ...writing.modules.where((m) => m.grade == grade),
        ...math.modules.where((m) => m.grade == grade),
      ];

      final visibleModules = <ModuleEntity>[];
      if (studentId != null && studentId.isNotEmpty) {
        for (final module in byGrade) {
          final pending = await _repository.getExercisesByModule(
            module.id,
            studentId: studentId,
            pendingOnly: true,
          );
          if (pending.failure == null && pending.exercises.isNotEmpty) {
            visibleModules.add(
              ModuleEntity(
                id: module.id,
                title: module.title,
                description: module.description,
                type: module.type,
                grade: module.grade,
                isActive: module.isActive,
                exerciseCount: pending.exercises.length,
                createdAt: module.createdAt,
              ),
            );
          }
        }
      } else {
        visibleModules.addAll(byGrade);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _modules = visibleModules;
      });
    } finally {
      _isReloading = false;
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos dias';
    if (h >= 12 && h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;
    final studentName = (authState.userName == null || authState.userName!.trim().isEmpty)
        ? 'estudiante'
        : authState.userName!.trim();
    final studentGrade = authState.studentGrade ?? 1;
    final studentPoints = authState.studentPoints;
    final studentPhotoUrl = authState.studentPhotoUrl;
    final studentId = authState.studentId;
    final modules = _modules;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          _StudentHeader(
            greeting: _greeting,
            name: studentName,
            grade: studentGrade,
            points: studentPoints,
            photoUrl: studentPhotoUrl,
            isRefreshing: _isReloading,
            onRefresh: () => _loadModules(showLoader: true),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _ModuleGrid(
                    modules: modules,
                    repository: _repository,
                    studentId: studentId,
                    onModulesNeedRefresh: _loadModules,
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({
    required this.greeting,
    required this.name,
    required this.grade,
    required this.points,
    required this.photoUrl,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final String greeting;
  final String name;
  final int grade;
  final int points;
  final String? photoUrl;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  ImageProvider _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const AssetImage('assets/images/buho_alumno.png');
    }

    final trimmed = value.trim();
    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        try {
          return MemoryImage(base64Decode(trimmed.substring(comma + 1)));
        } catch (_) {
          return const AssetImage('assets/images/buho_alumno.png');
        }
      }
    }

    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -20, right: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -10, left: 60,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                    ),
                    child: ClipOval(
                      child: Image(
                        image: _resolvePhotoProvider(photoUrl),
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.3),
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.face_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $name!',
                          style: const TextStyle(
                            fontSize: 22, fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Listo para aprender hoy?',
                          style: TextStyle(
                            fontSize: 13, fontFamily: 'Nunito',
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pill grado
                  _HeaderPill(
                    icon: Icons.school_rounded,
                    label: 'Grado $grade',
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Pill puntos
                  _HeaderPill(
                    icon: Icons.stars_rounded,
                    label: '$points pts',
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  Tooltip(
                    message: isRefreshing ? 'Actualizando...' : 'Actualizar',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: isRefreshing ? null : onRefresh,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.all(AppRadius.medium),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: isRefreshing
                              ? const Padding(
                                  padding: EdgeInsets.all(11),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  Tooltip(
                    message: 'Salir',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthNotifier>().logout();
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.login);
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius:
                                const BorderRadius.all(AppRadius.medium),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });
  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, fontFamily: 'Nunito',
            fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
      ]),
    );
  }
}


class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({
    required this.modules,
    required this.repository,
    required this.studentId,
    required this.onModulesNeedRefresh,
  });

  final List<ModuleEntity> modules;
  final ApiModuleRepository repository;
  final String? studentId;
  final Future<void> Function() onModulesNeedRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta superior
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(AppRadius.full),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Tus actividades de hoy',
                style: TextStyle(
                  fontSize: 13, fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700, color: AppColors.primary,
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Grid responsivo
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 3
                      : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.82,
                ),
                itemCount: modules.length + 1,
                itemBuilder: (_, i) {
                  if (i == modules.length) return const _GamificationCard();
                  return _ModuleCard(
                    module: modules[i],
                    repository: repository,
                    studentId: studentId,
                    onModulesNeedRefresh: onModulesNeedRefresh,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}


const _moduleIcons = {
  ModuleType.reading: Icons.menu_book_rounded,
  ModuleType.writing: Icons.edit_rounded,
  ModuleType.math: Icons.calculate_rounded,
};

const _moduleColors = {
  ModuleType.reading: Color(0xFF0D9488),
  ModuleType.writing: Color(0xFF8B5CF6),
  ModuleType.math: Color(0xFFF59E0B),
};

const _moduleGradients = {
  ModuleType.reading: [Color(0xFF0D9488), Color(0xFF14B8A6)],
  ModuleType.writing: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  ModuleType.math: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
};

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.module,
    required this.repository,
    required this.studentId,
    required this.onModulesNeedRefresh,
  });
  final ModuleEntity module;
  final ApiModuleRepository repository;
  final String? studentId;
  final Future<void> Function() onModulesNeedRefresh;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  late final AnimationController _bounceCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 180));
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.04).animate(
    CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _hovered = true);
    _bounceCtrl.forward();
  }

  void _onExit(_) {
    setState(() => _hovered = false);
    _bounceCtrl.reverse();
  }

  ModuleType  get _type     => widget.module.type;
  Color       get _color    => _moduleColors[_type]!;
  IconData    get _icon     => _moduleIcons[_type]!;
  List<Color> get _gradient => _moduleGradients[_type]!;

  int get _activeExerciseCount =>
      widget.module.exerciseCount;

  @override
  Widget build(BuildContext context) {
    final count = _activeExerciseCount;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ModuleDetailPage(
                module: widget.module,
                repository: widget.repository,
                isTeacher: false,
                studentId: widget.studentId,
              ),
            ),
          );
          if (!mounted) return;
          await widget.onModulesNeedRefresh();
        },
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              border: Border.all(
                color: _hovered
                    ? _color.withValues(alpha: 0.5)
                    : AppColors.border,
                width: _hovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _color.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: _hovered ? 24 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Parte superior: gradiente + emoji
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradient,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: AppRadius.xl),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -16, right: -16,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -8, left: -8,
                          child: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(_icon, size: 60, color: Colors.white),
                        ),
                        // Badge cantidad de ejercicios
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius:
                                  const BorderRadius.all(AppRadius.full),
                            ),
                            child: Text(
                              count == 0
                                  ? 'Sin ejercicios'
                                  : '$count ejercicio${count != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 10, fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                color: _color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Chip tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.1),
                            borderRadius:
                                const BorderRadius.all(AppRadius.full),
                          ),
                          child: Text(
                            _type.label,
                            style: TextStyle(
                              fontSize: 10, fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700, color: _color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.module.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14, fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              color: _color,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: _color),
                        ]),
                      ],
                    ),
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

class _GamificationCard extends StatelessWidget {
  const _GamificationCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aquí verás tus logros muy pronto.'),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  borderRadius: BorderRadius.vertical(top: AppRadius.xl),
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.all(AppRadius.full),
                      ),
                      child: const Text(
                        'Gamificación',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Mis Logros',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_top_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tu profe aun no ha\\nsubido ejercicios!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vuelve mas tarde',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}





