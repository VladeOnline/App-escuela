import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class ExercisePassageCard extends StatefulWidget {
  const ExercisePassageCard({super.key, required this.passage});
  final String passage;

  @override
  State<ExercisePassageCard> createState() => _ExercisePassageCardState();
}

class _ExercisePassageCardState extends State<ExercisePassageCard> {
  bool _expanded = false;

  bool get _needsToggle => widget.passage.length > 300;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        boxShadow: [BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
              border: Border(
                  bottom: BorderSide(color: AppColors.accent.withOpacity(0.15))),
            ),
            child: Row(children: [
              // Búho sin fondo negro — blendMode multiply elimina el negro
              SizedBox(
                width: 44, height: 44,
                child: Image.asset(
                  'assets/images/buho_motivando.png',
                  fit: BoxFit.contain,
                  color: Colors.transparent,
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Texto de apoyo',
                    style: TextStyle(fontSize: 13, fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700, color: AppColors.accent)),
                Text('Lee con atención antes de responder',
                    style: TextStyle(fontSize: 11, fontFamily: 'Nunito',
                        color: AppColors.accent.withOpacity(0.7))),
              ]),
              const Spacer(),
              if (_needsToggle)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: const BorderRadius.all(AppRadius.full),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_expanded ? 'Ver menos' : 'Ver más',
                            style: TextStyle(fontSize: 11, fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent)),
                        const SizedBox(width: 3),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 14, color: AppColors.accent,
                        ),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),

          // ── Texto ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: (!_needsToggle || _expanded)
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.passage,
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: const TextStyle(fontSize: 15, fontFamily: 'Nunito',
                    height: 1.7, color: AppColors.textPrimary),
              ),
              secondChild: Text(
                widget.passage,
                style: const TextStyle(fontSize: 15, fontFamily: 'Nunito',
                    height: 1.7, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}