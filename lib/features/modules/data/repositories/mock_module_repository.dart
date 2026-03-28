import '../../domain/entities/module_entities.dart';

/// Repositorio mock de módulos y ejercicios.
/// El Back reemplazará esto con llamadas reales a MongoDB.
/// El contrato (métodos públicos) NO cambia — solo esta implementación.
class MockModuleRepository {
  // ─── Módulos mock ─────────────────────────────────────────────────────────

  List<ModuleEntity> getModulesByType(ModuleType type) {
    return _modules.where((m) => m.type == type && m.isActive).toList();
  }

  ModuleEntity? getModuleById(String id) {
    try {
      return _modules.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Ejercicios mock ──────────────────────────────────────────────────────

  List<ExerciseEntity> getExercisesByModule(String moduleId) {
    return _exercises.where((e) => e.moduleId == moduleId).toList();
  }

  ExerciseEntity? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// TODO(back): reemplazar con POST /api/modules/:id/exercises
  Future<ExerciseEntity> createExercise(ExerciseEntity exercise) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _exercises.add(exercise);
    return exercise;
  }

  /// TODO(back): reemplazar con PATCH /api/exercises/:id/toggle
  Future<void> toggleExercise(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      final e = _exercises[index];
      _exercises[index] = ExerciseEntity(
        id: e.id,
        moduleId: e.moduleId,
        title: e.title,
        instructions: e.instructions,
        type: e.type,
        difficulty: e.difficulty,
        content: e.content,
        isActive: !e.isActive,
      );
    }
  }

  // ─── Datos seed ───────────────────────────────────────────────────────────

  final List<ModuleEntity> _modules = [
    // LECTURA
    ModuleEntity(
      id: 'mod-lec-1',
      title: 'Comprensión de textos',
      description:
          'Ejercicios para desarrollar la comprensión lectora mediante textos cortos y preguntas de análisis.',
      type: ModuleType.reading,
      grade: 2,
      exerciseCount: 3,
      createdAt: DateTime(2026, 2, 1),
    ),
    ModuleEntity(
      id: 'mod-lec-2',
      title: 'Vocabulario y sinónimos',
      description:
          'Actividades para ampliar el vocabulario e identificar sinónimos y antónimos en contexto.',
      type: ModuleType.reading,
      grade: 3,
      exerciseCount: 2,
      createdAt: DateTime(2026, 2, 5),
    ),
    // ESCRITURA
    ModuleEntity(
      id: 'mod-esc-1',
      title: 'Ortografía básica',
      description:
          'Práctica de reglas ortográficas fundamentales: uso de mayúsculas, puntuación y acento.',
      type: ModuleType.writing,
      grade: 2,
      exerciseCount: 3,
      createdAt: DateTime(2026, 2, 3),
    ),
    ModuleEntity(
      id: 'mod-esc-2',
      title: 'Construcción de oraciones',
      description:
          'Ejercicios para ordenar palabras y construir oraciones con sentido completo.',
      type: ModuleType.writing,
      grade: 3,
      exerciseCount: 2,
      createdAt: DateTime(2026, 2, 8),
    ),
  ];

  final List<ExerciseEntity> _exercises = [
    // ── LECTURA: Comprensión de textos (mod-lec-1) ────────────────────────

    ExerciseEntity(
      id: 'ex-lec-1-1',
      moduleId: 'mod-lec-1',
      title: '¿De qué trata el cuento?',
      instructions:
          'Lee el texto con atención y luego selecciona la respuesta correcta.',
      type: ExerciseType.multipleChoice,
      difficulty: DifficultyLevel.basic,
      content: {
        'passage':
            'El sol salió muy temprano esa mañana. Lucía se despertó, se lavó la cara y desayunó con su mamá. Después tomó su mochila y caminó hacia la escuela. Cuando llegó, sus amigos ya estaban jugando en el patio.',
        'question': '¿Qué hizo Lucía después de desayunar?',
        'options': [
          'Se fue a dormir',
          'Tomó su mochila y fue a la escuela',
          'Llamó a sus amigos',
          'Vio televisión',
        ],
        'correctIndex': 1,
      },
    ),

    ExerciseEntity(
      id: 'ex-lec-1-2',
      moduleId: 'mod-lec-1',
      title: '¿Verdadero o falso?',
      instructions:
          'Lee la afirmación y decide si es verdadera o falsa según el texto.',
      type: ExerciseType.trueOrFalse,
      difficulty: DifficultyLevel.basic,
      content: {
        'passage':
            'El sol salió muy temprano esa mañana. Lucía se despertó, se lavó la cara y desayunó con su mamá. Después tomó su mochila y caminó hacia la escuela. Cuando llegó, sus amigos ya estaban jugando en el patio.',
        'statement': 'Cuando Lucía llegó a la escuela, el patio estaba vacío.',
        'correctAnswer': false,
      },
    ),

    ExerciseEntity(
      id: 'ex-lec-1-3',
      moduleId: 'mod-lec-1',
      title: 'Completa la oración',
      instructions: 'Escribe la palabra que falta según el texto leído.',
      type: ExerciseType.fillInTheBlank,
      difficulty: DifficultyLevel.intermediate,
      content: {
        'passage':
            'El sol salió muy temprano esa mañana. Lucía se despertó, se lavó la cara y desayunó con su mamá. Después tomó su mochila y caminó hacia la escuela.',
        'template': 'Lucía caminó hacia la [BLANK] después de desayunar.',
        'correctAnswer': 'escuela',
        'hint': 'Es el lugar donde van los niños a aprender.',
      },
    ),

    // ── ESCRITURA: Ortografía básica (mod-esc-1) ──────────────────────────

    ExerciseEntity(
      id: 'ex-esc-1-1',
      moduleId: 'mod-esc-1',
      title: '¿Con mayúscula o minúscula?',
      instructions:
          'Selecciona si la palabra subrayada está escrita correctamente.',
      type: ExerciseType.multipleChoice,
      difficulty: DifficultyLevel.basic,
      content: {
        'question':
            '¿Cuál de estas opciones está escrita correctamente?',
        'options': [
          'el perro se llama max.',
          'El perro se llama Max.',
          'el Perro se llama max.',
          'El perro se llama max.',
        ],
        'correctIndex': 1,
        'explanation':
            'Los nombres propios y el inicio de oración siempre llevan mayúscula.',
      },
    ),

    ExerciseEntity(
      id: 'ex-esc-1-2',
      moduleId: 'mod-esc-1',
      title: 'Ordena las palabras',
      instructions:
          'Arrastra las palabras para formar una oración con sentido.',
      type: ExerciseType.ordering,
      difficulty: DifficultyLevel.intermediate,
      content: {
        'words': ['la', 'Ana', 'pintó', 'mariposa', 'una'],
        'correctOrder': ['Ana', 'pintó', 'una', 'mariposa'],
        'hint': 'La oración empieza con el nombre de la niña.',
      },
    ),

    ExerciseEntity(
      id: 'ex-esc-1-3',
      moduleId: 'mod-esc-1',
      title: '¿Verdad o mentira?',
      instructions:
          'Decide si la siguiente afirmación sobre ortografía es correcta.',
      type: ExerciseType.trueOrFalse,
      difficulty: DifficultyLevel.basic,
      content: {
        'statement':
            'Los nombres de personas siempre se escriben con letra mayúscula.',
        'correctAnswer': true,
        'explanation':
            'Correcto. Los nombres propios de personas, lugares y animales llevan mayúscula.',
      },
    ),
  ];
}
