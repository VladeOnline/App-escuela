// ─── CAMBIOS respecto al original ────────────────────────────────────────────
// Sección _moduleFromJson:
//   · creado_en ahora se parsea de forma segura — acepta tanto String como
//     objetos Date serializados por Mongoose, y tiene fallback a DateTime.now()
//     si el campo no viene o no es parseable.
//
// Sección createModule:
//   · La respuesta del POST devuelve el doc de Mongoose directamente.
//     Mongoose serializa los ObjectId como objetos { $oid: '...' } a veces,
//     así que el id se extrae con toString() en vez de cast directo.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/module_entities.dart';
import '../../domain/entities/subject.dart';

/// Repositorio real que reemplaza al MockModuleRepository.
/// Hace llamadas HTTP al backend en vez de usar datos hardcodeados.
class ApiModuleRepository {
  final String token;

  ApiModuleRepository({required this.token});

  // Headers que se mandan en cada request — incluye el token JWT
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<
    ({
      bool? isCorrect,
      int? pointsEarned,
      bool? alreadyRewarded,
      int? attemptsLeft,
      AppFailure? failure,
    })
  > submitExerciseAnswer({
    required String exerciseId,
    required String studentId,
    required dynamic answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios/$exerciseId/responder'),
        headers: _headers,
        body: jsonEncode({
          'estudiante_id': studentId,
          'respuesta_dada': answer,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final feedback =
            (data['retroalimentacion'] as Map?)?.cast<String, dynamic>() ??
                <String, dynamic>{};
        return (
          isCorrect: feedback['esCorrecta'] == true,
          pointsEarned: feedback['puntosObtenidos'] is int
              ? feedback['puntosObtenidos'] as int
              : int.tryParse('${feedback['puntosObtenidos'] ?? ''}') ?? 0,
          alreadyRewarded: feedback['yaRespondioCorrecto'] == true,
          attemptsLeft: feedback['intentosRestantes'] is int
              ? feedback['intentosRestantes'] as int
              : int.tryParse('${feedback['intentosRestantes'] ?? ''}'),
          failure: null,
        );
      }

      return (
        isCorrect: null,
        pointsEarned: null,
        alreadyRewarded: null,
        attemptsLeft: null,
        failure: _failureFromResponse(response, 'Error al registrar respuesta'),
      );
    } catch (_) {
      return (
        isCorrect: null,
        pointsEarned: null,
        alreadyRewarded: null,
        attemptsLeft: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Helpers de conversión: Backend → Frontend
  // ─────────────────────────────────────────────

  ModuleType _moduleTypeFromString(String tipo) => switch (tipo) {
    'escritura' => ModuleType.writing,
    'matematicas' => ModuleType.math,
    _ => ModuleType.reading,
  };

  DifficultyLevel _difficultyFromString(String dificultad) =>
      switch (dificultad) {
        'intermedio' => DifficultyLevel.intermediate,
        'avanzado' => DifficultyLevel.advanced,
        _ => DifficultyLevel.basic,
      };

  ExerciseType _exerciseTypeFromString(String tipo) => switch (tipo) {
    'verdadero_falso' => ExerciseType.trueOrFalse,
    'completar_espacio' => ExerciseType.fillInTheBlank,
    'ordenamiento' => ExerciseType.ordering,
    _ => ExerciseType.multipleChoice,
  };

  Subject _subjectFromString(String materia) => switch (materia) {
    'matematicas' => Subject.math,
    'ciencias' => Subject.science,
    'estudios_sociales' => Subject.socialStudies,
    _ => Subject.spanish,
  };

  // ─────────────────────────────────────────────
  // Helpers de conversión: Frontend → Backend
  // ─────────────────────────────────────────────

  String _moduleTypeToString(ModuleType type) => switch (type) {
    ModuleType.writing => 'escritura',
    ModuleType.math => 'matematicas',
    ModuleType.reading => 'lectura',
  };

  String _difficultyToString(DifficultyLevel d) => switch (d) {
    DifficultyLevel.intermediate => 'intermedio',
    DifficultyLevel.advanced => 'avanzado',
    DifficultyLevel.basic => 'basico',
  };

  String _exerciseTypeToString(ExerciseType type) => switch (type) {
    ExerciseType.trueOrFalse => 'verdadero_falso',
    ExerciseType.fillInTheBlank => 'completar_espacio',
    ExerciseType.ordering => 'ordenamiento',
    ExerciseType.multipleChoice => 'seleccion_multiple',
  };

  String _subjectToString(Subject s) => switch (s) {
    Subject.math => 'matematicas',
    Subject.science => 'ciencias',
    Subject.socialStudies => 'estudios_sociales',
    _ => 'español',
  };

  /// Construye un ModuleEntity a partir del JSON del backend.
  ///
  /// FIX: creado_en se parsea de forma defensiva porque Mongoose puede
  /// devolver el campo como String ISO, como objeto Date serializado,
  /// o incluso ausente en respuestas de POST recientes.
  ModuleEntity _moduleFromJson(Map<String, dynamic> json) {
    return ModuleEntity(
      id:
          json['_id']?.toString() ??
          '', // FIX: toString() por si viene como ObjectId
      title: json['titulo'] as String,
      description: (json['descripcion'] as String?) ?? '',
      type: _moduleTypeFromString(json['tipo_modulo'] as String),
      grade: json['grado'] as int,
      isActive: (json['activo'] as bool?) ?? true,
      exerciseCount: (json['totalEjercicios'] as int?) ?? 0,
      createdAt: _parseDate(json['creado_en']), // FIX: parser defensivo
    );
  }

  /// Parsea el campo creado_en de forma segura.
  /// Acepta: String ISO 8601, o null/cualquier otra cosa → DateTime.now().
  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Construye un ExerciseEntity a partir del JSON del backend.
  ExerciseEntity _exerciseFromJson(Map<String, dynamic> json) {
    return ExerciseEntity(
      id: json['_id']?.toString() ?? '',
      moduleId: json['contenido_id'] is Map
          ? (json['contenido_id'] as Map)['_id']?.toString() ?? ''
          : json['contenido_id']?.toString() ?? '',
      title: json['titulo'] as String,
      instructions: json['instrucciones'] as String,
      type: _exerciseTypeFromString(json['tipo'] as String),
      difficulty: _difficultyFromString(json['dificultad'] as String),
      subject: _subjectFromString(json['materia'] as String),
      content: (json['content'] as Map).cast<String, dynamic>(),
      isActive: (json['activo'] as bool?) ?? true,
    );
  }

  // ─────────────────────────────────────────────
  // Obtener contenidos por tipo de módulo
  // GET /api/contenidos?tipo_modulo=lectura
  // ─────────────────────────────────────────────
  Future<({List<ModuleEntity> modules, AppFailure? failure})> getModulesByType(
    ModuleType type,
  ) async {
    try {
      final tipoModulo = _moduleTypeToString(type);
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}/contenidos',
      ).replace(queryParameters: {'tipo_modulo': tipoModulo});

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = (data['contenidos'] as List).cast<Map<String, dynamic>>();
        final modules = lista.map(_moduleFromJson).toList();
        return (modules: modules, failure: null);
      }

      return (
        modules: <ModuleEntity>[],
        failure: _failureFromResponse(response, 'Error al cargar módulos'),
      );
    } catch (_) {
      return (
        modules: <ModuleEntity>[],
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Obtener un contenido por ID
  // GET /api/contenidos/:id
  // ─────────────────────────────────────────────
  Future<({ModuleEntity? module, AppFailure? failure})> getModuleById(
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/contenidos/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final contenido = (data['contenido'] as Map).cast<String, dynamic>();
        contenido['totalEjercicios'] = data['totalEjercicios'];
        return (module: _moduleFromJson(contenido), failure: null);
      }

      return (
        module: null,
        failure: _failureFromResponse(response, 'Error al cargar el módulo'),
      );
    } catch (_) {
      return (
        module: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Crear un contenido nuevo
  // POST /api/contenidos
  // ─────────────────────────────────────────────
  Future<({ModuleEntity? module, AppFailure? failure})> createModule(
    ModuleEntity module,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/contenidos'),
        headers: _headers,
        body: jsonEncode({
          'tipo_modulo': _moduleTypeToString(module.type),
          'titulo': module.title,
          'descripcion': module.description,
          'grado': module.grade,
        }),
      );
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}'); // ← agregá esta línea temporal

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // FIX: el backend devuelve el doc de Mongoose directamente bajo 'contenido'.
        // Mongoose serializa _id como objeto — _moduleFromJson ya lo maneja con toString().
        final contenido = (data['contenido'] as Map).cast<String, dynamic>();
        return (module: _moduleFromJson(contenido), failure: null);
      }

      return (
        module: null,
        failure: _failureFromResponse(response, 'Error al crear el módulo'),
      );
    } catch (_) {
      return (
        module: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Eliminar un contenido
  // DELETE /api/contenidos/:id
  // El backend rechaza si tiene ejercicios asociados.
  // ─────────────────────────────────────────────
  Future<AppFailure?> deleteModule(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/contenidos/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) return null;
      return _failureFromResponse(response, 'Error al eliminar el contenido');
    } catch (_) {
      return const ServerFailure('Sin conexión al servidor');
    }
  }

  // ─────────────────────────────────────────────
  // Obtener ejercicios de un contenido
  // GET /api/ejercicios?contenido_id=xxx
  // ─────────────────────────────────────────────
  Future<({List<ExerciseEntity> exercises, AppFailure? failure})>
  getExercisesByModule(
    String moduleId, {
    String? studentId,
    bool pendingOnly = false,
  }) async {
    try {
      final query = <String, String>{'contenido_id': moduleId};
      if (studentId != null && studentId.isNotEmpty) {
        query['estudiante_id'] = studentId;
        if (pendingOnly) query['pendientes'] = 'true';
      }
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}/ejercicios',
      ).replace(queryParameters: query);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = (data['ejercicios'] as List).cast<Map<String, dynamic>>();
        final exercises = lista.map(_exerciseFromJson).toList();
        return (exercises: exercises, failure: null);
      }

      return (
        exercises: <ExerciseEntity>[],
        failure: _failureFromResponse(response, 'Error al cargar ejercicios'),
      );
    } catch (_) {
      return (
        exercises: <ExerciseEntity>[],
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Crear un ejercicio nuevo
  // POST /api/ejercicios
  // ─────────────────────────────────────────────
  Future<({ExerciseEntity? exercise, AppFailure? failure})> createExercise(
    ExerciseEntity exercise,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios'),
        headers: _headers,
        body: jsonEncode({
          'contenido_id': exercise.moduleId,
          'titulo': exercise.title,
          'instrucciones': exercise.instructions,
          'tipo': _exerciseTypeToString(exercise.type),
          'dificultad': _difficultyToString(exercise.difficulty),
          'materia': _subjectToString(exercise.subject),
          'content': exercise.content,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ej = (data['ejercicio'] as Map).cast<String, dynamic>();
        return (exercise: _exerciseFromJson(ej), failure: null);
      }

      return (
        exercise: null,
        failure: _failureFromResponse(response, 'Error al crear el ejercicio'),
      );
    } catch (_) {
      return (
        exercise: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Editar un ejercicio
  // PUT /api/ejercicios/:id
  // ─────────────────────────────────────────────
  Future<({ExerciseEntity? exercise, AppFailure? failure})> updateExercise(
    ExerciseEntity exercise,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios/${exercise.id}'),
        headers: _headers,
        body: jsonEncode({
          'titulo': exercise.title,
          'instrucciones': exercise.instructions,
          'tipo': _exerciseTypeToString(exercise.type),
          'dificultad': _difficultyToString(exercise.difficulty),
          'materia': _subjectToString(exercise.subject),
          'content': exercise.content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ej = (data['ejercicio'] as Map).cast<String, dynamic>();
        return (exercise: _exerciseFromJson(ej), failure: null);
      }

      return (
        exercise: null,
        failure: _failureFromResponse(response, 'Error al editar el ejercicio'),
      );
    } catch (_) {
      return (
        exercise: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Toggle: activar o desactivar un ejercicio
  // PATCH /api/ejercicios/:id/toggle
  // ─────────────────────────────────────────────
  Future<AppFailure?> toggleExercise(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios/$id/toggle'),
        headers: _headers,
      );

      if (response.statusCode == 200) return null;
      return _failureFromResponse(
        response,
        'Error al cambiar estado del ejercicio',
      );
    } catch (_) {
      return const ServerFailure('Sin conexión al servidor');
    }
  }

  // ─────────────────────────────────────────────
  // Bulk toggle: activar/desactivar varios ejercicios
  // PATCH /api/ejercicios/bulk-toggle
  // ─────────────────────────────────────────────
  Future<AppFailure?> setExercisesActive(
    Iterable<String> ids, {
    required bool isActive,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios/bulk-toggle'),
        headers: _headers,
        body: jsonEncode({'ids': ids.toList(), 'activo': isActive}),
      );

      if (response.statusCode == 200) return null;
      return _failureFromResponse(response, 'Error al actualizar ejercicios');
    } catch (_) {
      return const ServerFailure('Sin conexión al servidor');
    }
  }

  // ─────────────────────────────────────────────
  // Eliminar un ejercicio
  // DELETE /api/ejercicios/:id
  // ─────────────────────────────────────────────
  Future<AppFailure?> deleteExercise(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/ejercicios/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) return null;
      return _failureFromResponse(response, 'Error al eliminar el ejercicio');
    } catch (_) {
      return const ServerFailure('Sin conexión al servidor');
    }
  }

  // ─────────────────────────────────────────────
  // Helper: construye un AppFailure desde la respuesta HTTP
  // ─────────────────────────────────────────────
  AppFailure _failureFromResponse(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = data['mensaje']?.toString() ?? data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return ServerFailure(msg);
    } catch (_) {}
    return ServerFailure(fallback);
  }
}
