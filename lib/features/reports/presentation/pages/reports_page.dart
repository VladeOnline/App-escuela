import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import 'grade_report_page.dart';
import 'historial_page.dart';
import 'individual_report_page.dart';
import 'progress_chart_page.dart';

/// Página raíz de Reportes. Contiene el TabBar superior y delega
/// cada tab a su propia página.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with TickerProviderStateMixin {
  late final TabController _tabs;

  static const _tabDefs = [
    _TabDef(icon: Icons.person_outline_rounded,    label: 'Individual'),
    _TabDef(icon: Icons.trending_up_rounded,        label: 'Progreso'),
    _TabDef(icon: Icons.groups_outlined,            label: 'Por Grado'),
    _TabDef(icon: Icons.history_rounded,            label: 'Historial'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabDefs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReportsTabBar(controller: _tabs, tabs: _tabDefs),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              IndividualReportPage(),
              ProgressChartPage(),
              GradeReportPage(),
              HistorialPage(),
            ],
          ),
        ),

      ],
    );
  }
}

// ── TabBar personalizado ──────────────────────────────────────────────────────

class _ReportsTabBar extends StatelessWidget {
  const _ReportsTabBar({
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<_TabDef> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceCard,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          fontSize: 13,
        ),
        tabs: tabs
            .map(
              (t) => Tab(
                icon: Icon(t.icon, size: 18),
                iconMargin: const EdgeInsets.only(bottom: 2),
                text: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef({required this.icon, required this.label});
}
