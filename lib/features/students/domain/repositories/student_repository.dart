import '../entities/student_entity.dart';
import '../../../../core/errors/app_failure.dart';

/// Contrato del repositorio de estudiantes.
/// El Back implementará la versión real contra MongoDB.
/// Por ahora existe la versión mock en data/repositories.
abstract interface class StudentRepository {
  /// Obtiene todos los estudiantes activos.
  Future<({List<StudentEntity> students, AppFailure? failure})> getAll();

  /// Busca estudiantes por nombre o grado (RF-31).
  Future<({List<StudentEntity> students, AppFailure? failure})> search({
    String? name,
    int? grade,
  });

  /// Registra un nuevo estudiante (RF-01).
  Future<
      ({
        StudentEntity? student,
        String? generatedUsername,
        String? generatedPassword,
        AppFailure? failure
      })> create({
    required String fullName,
    required int grade,
    required int age,
  });

  /// Edita la información de un estudiante (RF-02).
  Future<({StudentEntity? student, AppFailure? failure})> update({
    required String id,
    required String fullName,
    required int grade,
    required int age,
  });

  /// Elimina un estudiante del sistema (RF-03).
  Future<({bool success, AppFailure? failure})> delete(String id);

  /// Desactiva un estudiante sin eliminarlo (RF-42).
  Future<({bool success, AppFailure? failure})> deactivate(String id);
}
