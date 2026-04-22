import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../modules/data/repositories/api_module_repository.dart';
import '../../../modules/domain/entities/module_entities.dart';
import '../widgets/home/student_header.dart';
import '../widgets/home/subject_card.dart';
import 'achievements_page.dart';
import 'exercise_level_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  late ApiModuleRepository _repository;

  int _readingCount = 0;
  int _writingCount = 0;
  int _mathCount = 0;
  bool _isLoading = true;
  bool _isReloading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthNotifier>().state.token ?? '';
    _repository = ApiModuleRepository(token: token);
    _loadPendingCounts(showLoader: true);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadPendingCounts(),
    );
  }

  Future<void> _loadPendingCounts({bool showLoader = false}) async {
    if (_isReloading) return;
    _isReloading = true;

    if (showLoader && mounted) setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthNotifier>().state;
      final grade = authState.studentGrade ?? 1;
      final studentId = authState.studentId ?? '';

      final readingRes = await _repository.getModulesByType(ModuleType.reading);
      final writingRes = await _repository.getModulesByType(ModuleType.writing);
      final mathRes = await _repository.getModulesByType(ModuleType.math);

      int reading = 0;
      int writing = 0;
      int math = 0;

      final readingModules = readingRes.modules.where((m) => m.grade == grade);
      final writingModules = writingRes.modules.where((m) => m.grade == grade);
      final mathModules = mathRes.modules.where((m) => m.grade == grade);

      Future<void> accumulateForModules(
        Iterable<ModuleEntity> modules,
        ModuleType defaultBucket,
      ) async {
        for (final m in modules) {
          final r = await _repository.getExercisesByModule(
            m.id,
            studentId: studentId.isNotEmpty ? studentId : null,
            pendingOnly: studentId.isNotEmpty,
          );
          if (r.failure != null) continue;

          for (final exercise in r.exercises) {
            if (exercise.subject == Subject.math) {
              math += 1;
              continue;
            }
            switch (defaultBucket) {
              case ModuleType.reading:
                reading += 1;
                break;
              case ModuleType.writing:
                writing += 1;
                break;
              case ModuleType.math:
                math += 1;
                break;
            }
          }
        }
      }

      await accumulateForModules(readingModules, ModuleType.reading);
      await accumulateForModules(writingModules, ModuleType.writing);
      await accumulateForModules(mathModules, ModuleType.math);

      if (!mounted) return;
      setState(() {
        _readingCount = reading;
        _writingCount = writing;
        _mathCount = math;
        _isLoading = false;
      });
    } finally {
      _isReloading = false;
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos días';
    if (h >= 12 && h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  void _navigateTo(ModuleType type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExerciseLevelPage(
        moduleType: type,
        repository: _repository,
      ),
    )).then((_) => _loadPendingCounts());
  }

  void _navigateToAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AchievementsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;
    final name = (authState.userName?.trim().isNotEmpty ?? false)
        ? authState.userName!.trim()
        : 'estudiante';

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          StudentHeader(
            greeting: _greeting,
            name: name,
            grade: authState.studentGrade ?? 1,
            points: authState.studentPoints,
            photoUrl: authState.studentPhotoUrl,
            isRefreshing: _isReloading,
            onRefresh: () => _loadPendingCounts(showLoader: true),
            onLogout: () {
              context.read<AuthNotifier>().logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _HomeGrid(
                    readingCount: _readingCount,
                    writingCount: _writingCount,
                    mathCount: _mathCount,
                    onSubjectTap: _navigateTo,
                    onAchievementsTap: _navigateToAchievements,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid de cards
// ---------------------------------------------------------------------------

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({
    required this.readingCount,
    required this.writingCount,
    required this.mathCount,
    required this.onSubjectTap,
    required this.onAchievementsTap,
  });

  final int readingCount;
  final int writingCount;
  final int mathCount;
  final void Function(ModuleType) onSubjectTap;
  final VoidCallback onAchievementsTap;

  @override
  Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth >= 500 ? 4 : 2;
              const spacing = AppSpacing.md;
              final cardWidth =
                  (constraints.maxWidth - spacing * (crossCount - 1)) /
                      crossCount;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cardItem(cardWidth, SubjectCard(
                    moduleType: ModuleType.reading,
                    pendingCount: readingCount,
                    onTap: () => onSubjectTap(ModuleType.reading),
                  )),
                  const SizedBox(width: spacing),
                  _cardItem(cardWidth, SubjectCard(
                    moduleType: ModuleType.writing,
                    pendingCount: writingCount,
                    onTap: () => onSubjectTap(ModuleType.writing),
                  )),
                  const SizedBox(width: spacing),
                  _cardItem(cardWidth, SubjectCard(
                    moduleType: ModuleType.math,
                    pendingCount: mathCount,
                    onTap: () => onSubjectTap(ModuleType.math),
                  )),
                  const SizedBox(width: spacing),
                  _cardItem(cardWidth, AchievementsCard(
                    onTap: onAchievementsTap,
                  )),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    ),
  );
}

Widget _cardItem(double width, Widget child) =>
    SizedBox(width: width, child: child);
}

// ---------------------------------------------------------------------------
// Etiqueta de sección
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 16),
          SizedBox(width: 6),
          Text(
            'Tus actividades de hoy',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
