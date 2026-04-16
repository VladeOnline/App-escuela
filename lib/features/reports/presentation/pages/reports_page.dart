import 'package:flutter/material.dart';
import 'individual_report_page.dart';
import 'progress_chart_page.dart';
import 'grade_report_page.dart';
import 'historial_page.dart';

/// Página principal de reportes con TabBar para navegar entre tipos
class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: 'Individual',
              ),
              Tab(
                icon: Icon(Icons.trending_up),
                text: 'Progreso',
              ),
              Tab(
                icon: Icon(Icons.groups),
                text: 'Por Grado',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Historial',
              ),
            ],
          ),
        ),
        
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
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
