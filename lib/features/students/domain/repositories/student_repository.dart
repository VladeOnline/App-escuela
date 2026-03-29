import '../entities/student_entity.dart';
import '../../../../core/errors/app_failure.dart';

abstract interface class StudentRepository {
  Future<({List<StudentEntity> students, AppFailure? failure})> getAll();

  Future<({List<StudentEntity> students, AppFailure? failure})> search({
    String? name,
    int? grade,
  });

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
    List<String> conditions = const [],
  });

  Future<({StudentEntity? student, AppFailure? failure})> update({
    required String id,
    required String fullName,
    required int grade,
    required int age,
    List<String> conditions = const [],
  });

  Future<({bool success, AppFailure? failure})> delete(String id);

  Future<({bool success, AppFailure? failure})> deactivate(String id);
}
