import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../modules/presentation/widgets/exercise_form/form_background.dart';
import '../../../ranking/data/ranking_repository.dart';
import '../../domain/entities/achievement_entity.dart';
import '../widgets/achievements/achievements_tab.dart';
import '../widgets/achievements/ranking_tab.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RankingRepository _rankingRepo;
  int _rankingRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    final token = context.read<AuthNotifier>().state.token ?? '';
    _rankingRepo = RankingRepository(token: token);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      setState(() => _rankingRefreshToken++);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;
    final points = authState.studentPoints;
    final grade = authState.studentGrade ?? 1;
    final studentId = authState.studentId ?? '';
    final achievements = AchievementsMockData.forStudent(points: points);
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ExFormBackground()),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Tooltip(
                            message: 'Volver',
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius:
                                  const BorderRadius.all(AppRadius.medium),
                              child: InkWell(
                                borderRadius:
                                    const BorderRadius.all(AppRadius.medium),
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () => Navigator.of(context).pop(),
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.arrow_back_rounded,
                                      color: AppColors.textPrimary, size: 20),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC4899)
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  const BorderRadius.all(AppRadius.full),
                              border: Border.all(
                                  color: const Color(0xFFEC4899)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events_rounded,
                                    size: 14, color: Color(0xFFEC4899)),
                                const SizedBox(width: 5),
                                Text(
                                  '$unlocked/${achievements.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEC4899),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Tabs del mismo ancho que la card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius:
                              const BorderRadius.all(AppRadius.large),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFFEC4899),
                            borderRadius:
                                const BorderRadius.all(AppRadius.medium),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: const [
                            Tab(text: 'Mis Logros'),
                            Tab(text: 'Ranking'),
                          ],
                        ),
                      ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),

                // Contenido con flechitas a los lados
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.lg),
                        child: _NavArrow(
                          icon: Icons.chevron_left_rounded,
                          onTap: () {},
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            AchievementsTab(achievements: achievements),
                            RankingTab(
                              repository: _rankingRepo,
                              grade: grade,
                              studentId: studentId,
                              studentPoints: points,
                              refreshToken: _rankingRefreshToken,
                            ),
                          ],
                        ),
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: _NavArrow(
                          icon: Icons.chevron_right_rounded,
                          onTap: () {},
                        ),
                      ),
                    ],
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

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: _pink.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: _pink.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
