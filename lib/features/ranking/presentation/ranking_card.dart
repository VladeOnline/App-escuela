import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../data/ranking_repository.dart';
import 'ranking_notifier.dart';

// Se puede usar tanto en TeacherDashboard como en StudentHomePage.
// En modo estudiante (highlightStudentId != null) resalta la fila del alumno.

class RankingCard extends StatefulWidget {
  const RankingCard({
    super.key,
    required this.grade,
    required this.token,
    this.highlightStudentId,
    this.compact = false,
  });

  /// Grado cuyos alumnos se muestran en el ranking.
  final int grade;

  /// JWT del usuario autenticado.
  final String token;

  /// Si no es null, resalta esa fila (util en el home del estudiante).
  final String? highlightStudentId;

  /// En modo compacto muestra solo top 5 sin selector de periodo.
  final bool compact;

  @override
  State<RankingCard> createState() => _RankingCardState();
}

class _RankingCardState extends State<RankingCard> {
  late final RankingNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = RankingNotifier(
      repository: RankingRepository(token: widget.token),
    );
    _notifier.loadRanking(grade: widget.grade);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<RankingNotifier>(
        builder: (_, notifier, __) {
          final state = notifier.state;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.all(AppRadius.xl),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RankingHeader(
                  grade: widget.grade,
                  selectedPeriod: state.selectedPeriod,
                ),
                _RankingBody(
                  state: state,
                  highlightId: widget.highlightStudentId,
                  compact: widget.compact,
                  onRetry: () => notifier.loadRanking(grade: widget.grade),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Header

class _RankingHeader extends StatelessWidget {
  const _RankingHeader({
    required this.grade,
    required this.selectedPeriod,
  });

  final int grade;
  final RankingPeriod selectedPeriod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.all(AppRadius.medium),
            ),
            child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito', color: Colors.white,
                  ),
                ),
                Text(
                  '${_gradeName(grade)} - ${selectedPeriod.label}',
                  style: TextStyle(
                    fontSize: 11, fontFamily: 'Nunito',
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _gradeName(int g) => switch (g) {
        1 => '1er grado', 2 => '2do grado', 3 => '3er grado',
        4 => '4to grado', 5 => '5to grado', _ => '6to grado',
      };
}


class _RankingBody extends StatelessWidget {
  const _RankingBody({
    required this.state,
    required this.highlightId,
    required this.compact,
    required this.onRetry,
  });

  final RankingState state;
  final String? highlightId;
  final bool compact;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      RankingStatus.loading => const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
      RankingStatus.failure => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textHint, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage ?? 'Error al cargar ranking',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13, fontFamily: 'Nunito', color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      RankingStatus.loaded when state.entries.isEmpty => const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Text(
              'Aun no hay puntos registrados\npara este periodo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontFamily: 'Nunito', color: AppColors.textSecondary, height: 1.6,
              ),
            ),
          ),
        ),
      _ => _RankingList(
          entries: compact ? state.entries.take(5).toList() : state.entries,
          highlightId: highlightId,
          maxPoints: state.entries.isEmpty ? 1 : state.entries.first.puntos,
        ),
    };
  }
}


class _RankingList extends StatelessWidget {
  const _RankingList({
    required this.entries,
    required this.highlightId,
    required this.maxPoints,
  });

  final List<RankingEntry> entries;
  final String? highlightId;
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 420,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: entries.map((e) {
                return _RankingRow(
                  entry: e,
                  isHighlight: e.estudianteId == highlightId,
                  maxPoints: maxPoints,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}


class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.entry,
    required this.isHighlight,
    required this.maxPoints,
  });

  final RankingEntry entry;
  final bool isHighlight;
  final int maxPoints;

  static const _medals = {1: '#1', 2: '#2', 3: '#3'};

  static const _avatarColors = [
    Color(0xFF0D9488), Color(0xFFF59E0B), Color(0xFF3B82F6),
    Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF10B981),
  ];

  Color _avatarColor() {
    final idx = entry.nombre.codeUnits.fold(0, (a, b) => a + b) % _avatarColors.length;
    return _avatarColors[idx];
  }

  String _initials() {
    final parts = entry.nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return entry.nombre.isNotEmpty ? entry.nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final barFraction = maxPoints > 0 ? entry.puntos / maxPoints : 0.0;
    final medal = _medals[entry.posicion];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: isHighlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Posicion
          SizedBox(
            width: 28,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center)
                : Text(
                    '#${entry.posicion}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          _Avatar(
            fotoUrl: entry.fotoUrl,
            initials: _initials(),
            color: _avatarColor(),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Nombre + barra
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nombre,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Nunito',
                    fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: const BorderRadius.all(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: barFraction.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _medalColor(entry.posicion),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Puntos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.all(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, size: 12, color: AppColors.secondary),
                const SizedBox(width: 3),
                Text(
                  '${entry.puntos}',
                  style: const TextStyle(
                    fontSize: 13, fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700, color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _medalColor(int pos) => switch (pos) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => AppColors.primary,
      };
}


class _Avatar extends StatelessWidget {
  const _Avatar({required this.fotoUrl, required this.initials, required this.color});
  final String? fotoUrl;
  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: ClipOval(
        child: fotoUrl != null && fotoUrl!.startsWith('data:image/')
            ? Image.memory(
                Uri.parse(fotoUrl!).data!.contentAsBytes(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: color,
          ),
        ),
      );
}

// Widget de posicion personal (para StudentHomePage)
// Muestra un resumen rapido del estudiante.

class StudentRankingPositionRow extends StatefulWidget {
  const StudentRankingPositionRow({
    super.key,
    required this.studentId,
    required this.grade,
    required this.token,
  });

  final String studentId;
  final int grade;
  final String token;

  @override
  State<StudentRankingPositionRow> createState() => _StudentRankingPositionRowState();
}

class _StudentRankingPositionRowState extends State<StudentRankingPositionRow> {
  late final RankingNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = RankingNotifier(
      repository: RankingRepository(token: widget.token),
    );
    _notifier.loadStudentPositions(
      studentId: widget.studentId,
      grade: widget.grade,
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<RankingNotifier>(
        builder: (_, notifier, __) {
          final positions = notifier.state.studentPositions;
          if (positions.isEmpty) {
            return const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            );
          }

          final totalData = positions[RankingPeriod.total];
          final semanaData = positions[RankingPeriod.semana];
          final currentPosition = totalData?.posicion ?? semanaData?.posicion;
          final totalPoints = totalData?.puntos ?? 0;
          final totalStudents = totalData?.totalEstudiantes ?? 0;
          final nextTarget = _nextBadgeTarget(totalPoints);
          final remaining =
              nextTarget == null ? 0 : (nextTarget - totalPoints).clamp(0, 999999);

          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Posicion actual',
                  value: currentPosition == null ? '-' : '#$currentPosition',
                  subtitle: totalStudents > 0 ? 'de $totalStudents alumnos' : '',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.stars_rounded,
                  title: 'Puntos totales',
                  value: '$totalPoints',
                  subtitle: 'puntos acumulados',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.flag_rounded,
                  title: 'Proxima insignia',
                  value: nextTarget == null ? 'Maximo' : '$nextTarget pts',
                  subtitle: nextTarget == null ? 'meta completada' : 'faltan $remaining pts',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Nunito',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Nunito',
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

int? _nextBadgeTarget(int points) {
  const targets = [10, 30, 50, 75, 100, 130, 170, 220, 300];
  for (final target in targets) {
    if (points < target) return target;
  }
  return null;
}
