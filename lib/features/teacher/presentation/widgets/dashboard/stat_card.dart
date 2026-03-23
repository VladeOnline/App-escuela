import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/dashboard_stat.dart';
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});
  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: const BorderRadius.all(AppRadius.medium),
            ),
            child: Icon(stat.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.value, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                Text(stat.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Nunito'), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (stat.sublabel != null)
                  Text(stat.sublabel!, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontFamily: 'Nunito')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}