import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../ranking/data/ranking_repository.dart';

class RankingTab extends StatefulWidget {
  const RankingTab({
    super.key,
    required this.repository,
    required this.grade,
    required this.studentId,
    required this.studentPoints,
    required this.refreshToken,
  });

  final RankingRepository repository;
  final int grade;
  final String studentId;
  final int studentPoints;
  final int refreshToken;

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> {
  RankingPeriod _period = RankingPeriod.total;
  RankingResult? _result;
  bool _isLoading = true;
  int _activeRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  @override
  void didUpdateWidget(covariant RankingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.grade != widget.grade ||
        oldWidget.studentPoints != widget.studentPoints ||
        oldWidget.refreshToken != widget.refreshToken) {
      _loadRanking();
    }
  }

  Future<void> _loadRanking() async {
    final requestId = ++_activeRequestId;
    setState(() => _isLoading = true);
    final result = await widget.repository.getRanking(
      grade: widget.grade,
      period: _period,
      top: 10,
    );
    if (!mounted || requestId != _activeRequestId) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  void _changePeriod(RankingPeriod p) {
    if (p == _period) return;
    setState(() {
      _period = p;
      _result = null;
    });
    _loadRanking();
  }

  String get _gradeName {
    const names = {
      1: 'Primer grado', 2: 'Segundo grado', 3: 'Tercer grado',
      4: 'Cuarto grado', 5: 'Quinto grado',  6: 'Sexto grado',
    };
    return names[widget.grade] ?? 'Grado ${widget.grade}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.all(AppRadius.xl),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtítulo
                  Row(
                    children: [
                      const Icon(Icons.leaderboard_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      const Text(
                        'Primeros lugares de: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Nunito',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _gradeName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Selector período
                  _PeriodSelector(
                      selected: _period, onChanged: _changePeriod),
                  const SizedBox(height: AppSpacing.lg),

                  // Contenido
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(
                            color: Color(0xFFEC4899)),
                      ),
                    )
                  else if (_result?.failure != null)
                    _ErrorState(onRetry: _loadRanking)
                  else if (_result == null || _result!.entries.isEmpty)
                    _EmptyState(period: _period)
                  else
                    _RankingList(
                      entries: _result!.entries,
                      studentId: widget.studentId,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});
  final RankingPeriod selected;
  final void Function(RankingPeriod) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in RankingPeriod.values)
            _PeriodChip(
              label: p.label,
              isSelected: p == selected,
              onTap: () => onChanged(p),
            ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip(
      {required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _pink : Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.small),
          boxShadow: isSelected
              ? [BoxShadow(color: _pink.withValues(alpha: 0.3), blurRadius: 6)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  const _RankingList({required this.entries, required this.studentId});
  final List<RankingEntry> entries;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _RankingRow(
            entry: entries[i],
            isCurrentStudent: entries[i].estudianteId == studentId,
          ),
        ],
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry, required this.isCurrentStudent});
  final RankingEntry entry;
  final bool isCurrentStudent;

  static const _pink = Color(0xFFEC4899);
  static const _posColors = {
    1: Color(0xFFF59E0B),
    2: Color(0xFF94A3B8),
    3: Color(0xFFCD7F32),
  };

  ImageProvider _photo(String? v) {
    if (v == null || v.trim().isEmpty) {
      return const AssetImage('assets/images/buho_alumno.png');
    }
    final t = v.trim();
    if (t.startsWith('data:image/')) {
      final c = t.indexOf(',');
      if (c > 0) {
        try { return MemoryImage(base64Decode(t.substring(c + 1))); } catch (_) {}
      }
    }
    return NetworkImage(t);
  }

  @override
  Widget build(BuildContext context) {
    final pos = entry.posicion;
    final posColor = _posColors[pos] ?? AppColors.textSecondary;
    final isTop3 = pos <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isCurrentStudent
            ? _pink.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: isCurrentStudent
              ? _pink.withValues(alpha: 0.3)
              : AppColors.border,
          width: isCurrentStudent ? 1.5 : 1,
        ),
        boxShadow: isTop3
            ? [BoxShadow(
                color: posColor.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3))]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Center(
              child: isTop3
                  ? Icon(Icons.emoji_events_rounded,
                      color: posColor, size: 22)
                  : Text('$pos',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isTop3
                    ? posColor.withValues(alpha: 0.5)
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image(
                image: _photo(entry.fotoUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.face_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.nombre,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Nunito',
                fontWeight:
                    isCurrentStudent ? FontWeight.w800 : FontWeight.w600,
                color: isCurrentStudent ? _pink : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isTop3
                  ? posColor.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: const BorderRadius.all(AppRadius.full),
            ),
            child: Text(
              '${entry.puntos} pts',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: isTop3 ? posColor : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.period});
  final RankingPeriod period;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.leaderboard_rounded,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text('Sin datos para ${period.label.toLowerCase()}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          const Text('No se pudo cargar el ranking'),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
