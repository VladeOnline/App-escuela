/// Constantes globales de la aplicación.
abstract class AppConstants {
  // App info
  static const appName = 'Refuerzo Escolar';
  static const appVersion = '1.0.0';

  // Grados disponibles
  static const grades = [1, 2, 3, 4, 5, 6];
  static const gradeLabels = {
    1: 'Primer grado',
    2: 'Segundo grado',
    3: 'Tercer grado',
    4: 'Cuarto grado',
    5: 'Quinto grado',
    6: 'Sexto grado',
  };

  // Validaciones
  static const minAge = 5;
  static const maxAge = 15;
  static const minNameLength = 2;
  static const maxNameLength = 60;

  // Roles
  static const roleTeacher = 'docente';
  static const roleStudent = 'estudiante';

  // Mock credentials (hasta que Back conecte auth real)
  static const mockTeacherPassword = '1234';

  // Storage keys (del equipo — auth_provider original)
  // El Back los usará cuando conecte el token JWT real.
  static const tokenKey = 'auth_token';
  static const roleKey = 'user_role';

  // API (del equipo — api_config original)
  // Cambiar la URL cuando Back defina el endpoint de producción.
  static const apiBaseUrl = 'http://localhost:3000/api';
}
