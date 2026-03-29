import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';

class MockStudentRepository implements StudentRepository {
  MockStudentRepository() {
    _seed();
  }

  final _uuid = const Uuid();
  final List<StudentEntity> _students = [];

  void _seed() {
    final seeds = [
      ('Maria Gonzalez', 1, 7),
      ('Carlos Rodriguez', 2, 8),
      ('Sofia Jimenez', 3, 9),
      ('Luis Perez', 4, 10),
      ('Valeria Mora', 5, 11),
      ('Andres Castro', 6, 12),
      ('Isabella Vargas', 1, 6),
      ('Diego Herrera', 3, 9),
    ];

    for (final (name, grade, age) in seeds) {
      _students.add(StudentEntity(
        id: _uuid.v4(),
        fullName: name,
        grade: grade,
        age: age,
        createdAt: DateTime.now().subtract(
          Duration(days: seeds.indexOf((name, grade, age)) * 3),
        ),
      ));
    }
  }

  @override
  Future<({List<StudentEntity> students, AppFailure? failure})> getAll() async {
    await _simulateDelay();
    final active = _students.where((s) => s.isActive).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return (students: active, failure: null);
  }

  @override
  Future<({List<StudentEntity> students, AppFailure? failure})> search({
    String? name,
    int? grade,
  }) async {
    await _simulateDelay();
    var results = _students.where((s) => s.isActive).toList();

    if (name != null && name.trim().isNotEmpty) {
      final query = name.trim().toLowerCase();
      results = results
          .where((s) => s.fullName.toLowerCase().contains(query))
          .toList();
    }

    if (grade != null) {
      results = results.where((s) => s.grade == grade).toList();
    }

    results.sort((a, b) => a.fullName.compareTo(b.fullName));
    return (students: results, failure: null);
  }

  @override
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
  }) async {
    await _simulateDelay();

    final trimmedName = fullName.trim();
    final student = StudentEntity(
      id: _uuid.v4(),
      fullName: trimmedName,
      grade: grade,
      age: age,
      conditions: conditions,
      createdAt: DateTime.now(),
    );

    _students.add(student);
    return (
      student: student,
      generatedUsername: trimmedName,
      generatedPassword: '$trimmedName$age',
      failure: null,
    );
  }

  @override
  Future<({StudentEntity? student, AppFailure? failure})> update({
    required String id,
    required String fullName,
    required int grade,
    required int age,
    List<String> conditions = const [],
  }) async {
    await _simulateDelay();
    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) {
      return (
        student: null,
        failure: const NotFoundFailure('Estudiante no encontrado'),
      );
    }

    final updated = _students[index].copyWith(
      fullName: fullName.trim(),
      grade: grade,
      age: age,
      conditions: conditions,
    );
    _students[index] = updated;
    return (student: updated, failure: null);
  }

  @override
  Future<({bool success, AppFailure? failure})> delete(String id) async {
    await _simulateDelay();

    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) {
      return (
        success: false,
        failure: const NotFoundFailure('Estudiante no encontrado'),
      );
    }

    _students.removeAt(index);
    return (success: true, failure: null);
  }

  @override
  Future<({bool success, AppFailure? failure})> deactivate(String id) async {
    await _simulateDelay();

    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) {
      return (
        success: false,
        failure: const NotFoundFailure('Estudiante no encontrado'),
      );
    }

    _students[index] = _students[index].copyWith(isActive: false);
    return (success: true, failure: null);
  }

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 300));
}
