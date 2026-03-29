import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_notifier.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/students/data/repositories/api_student_repository.dart';
import 'features/students/domain/usecases/validate_student_usecase.dart';
import 'features/students/presentation/notifiers/students_notifier.dart';
import 'features/students/presentation/pages/student_home_page.dart';
import 'features/teacher/presentation/pages/teacher_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'Refuerzo Escolar',
      minimumSize: Size(1024, 680),
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
      await Future.delayed(const Duration(milliseconds: 200));
      await windowManager.maximize();
    },
  );

  runApp(const AppEscuela());
}

class AppEscuela extends StatelessWidget {
  const AppEscuela({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProxyProvider<AuthNotifier, StudentsNotifier>(
          create: (_) => StudentsNotifier(
            repository: ApiStudentRepository(token: ''),
            validator: ValidateStudentUseCase(),
          ),
          update: (_, auth, previous) => StudentsNotifier(
            repository: ApiStudentRepository(token: auth.state.token ?? ''),
            validator: ValidateStudentUseCase(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Refuerzo Escolar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.teacherHome: (_) => const TeacherDashboardPage(),
          AppRoutes.studentHome: (_) => const StudentHomePage(),
        },
      ),
    );
  }
}
