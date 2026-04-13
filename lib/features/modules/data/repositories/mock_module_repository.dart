/*import '../../domain/entities/module_entities.dart';

/// Repositorio mock de módulos y ejercicios.
class MockModuleRepository {

  // ─── Módulos ───
  // TODO(back): GET /api/modules?type={reading|writing}
  List<ModuleEntity> getModulesByType(ModuleType type) =>
      _modules.where((m) => m.type == type && m.isActive).toList();

  // TODO(back): GET /api/modules/:id
  ModuleEntity? getModuleById(String id) {
    try { return _modules.firstWhere((m) => m.id == id); } catch (_) { return null; }
  }

  // ─── Ejercicios ───

  // TODO(back): GET /api/modules/:moduleId/exercises
  // Respuesta esperada: List<ExerciseEntity> con todos los campos incluyendo content
  List<ExerciseEntity> getExercisesByModule(String moduleId) =>
      _exercises.where((e) => e.moduleId == moduleId).toList();

  // TODO(back): GET /api/exercises/:id
  ExerciseEntity? getExerciseById(String id) {
    try { return _exercises.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  /// TODO(back): POST /api/modules/:moduleId/exercises
  /// Body: { title, instructions, type, difficulty, subject, content, isActive }
  /// Respuesta: ExerciseEntity completo con id generado por el servidor
  /// El campo content varía según type:
  ///   multipleChoice  → { passage?, question, options: [], correctIndex, explanation? }
  ///   trueOrFalse     → { passage?, statement, correctAnswer: bool, explanation? }
  ///   fillInTheBlank  → { template (con [BLANK]), correctAnswer, hint? }
  ///   ordering        → { words: [], correctOrder: [] }
  Future<ExerciseEntity> createExercise(ExerciseEntity exercise) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _exercises.add(exercise);
    return exercise;
  }

  /// TODO(back): PUT /api/exercises/:id
  /// Body: mismo esquema que createExercise
  /// Respuesta: ExerciseEntity actualizado
  /// Importante: conservar el isActive original si no se envía en el body
  Future<ExerciseEntity> updateExercise(ExerciseEntity exercise) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) _exercises[index] = exercise;
    return exercise;
  }

  /// TODO(back): PATCH /api/exercises/:id/toggle
  /// Body: ninguno — el servidor invierte el isActive actual
  /// Respuesta: { id, isActive: bool }
  Future<void> toggleExercise(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      _exercises[index] = _copyWith(_exercises[index], isActive: !_exercises[index].isActive);
    }
  }

  /// TODO(back): PATCH /api/exercises/bulk-toggle
  /// Body: { ids: [], isActive: bool }
  /// Respuesta: { updated: int } — cantidad de ejercicios afectados
  Future<void> setExercisesActive(Iterable<String> ids, {required bool isActive}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idSet = ids.toSet();
    for (var i = 0; i < _exercises.length; i++) {
      if (idSet.contains(_exercises[i].id)) {
        _exercises[i] = _copyWith(_exercises[i], isActive: isActive);
      }
    }
  }

  /// TODO(back): DELETE /api/exercises/:id
  /// Respuesta: 204 No Content
  /// Considerar soft delete (isActive: false) en lugar de borrado físico
  Future<void> deleteExercise(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _exercises.removeWhere((e) => e.id == id);
  }

  ExerciseEntity _copyWith(ExerciseEntity e, {bool? isActive}) => ExerciseEntity(
        id: e.id,
        moduleId: e.moduleId,
        title: e.title,
        instructions: e.instructions,
        type: e.type,
        difficulty: e.difficulty,
        subject: e.subject,
        content: e.content,
        isActive: isActive ?? e.isActive,
      );

  // ─── Datos seed ───────────────────────────────────────────────────
  // TODO(back): eliminar todo lo de abajo cuando la API esté conectada

  final List<ModuleEntity> _modules = [
    ModuleEntity(id: 'mod-lec-1', title: 'Comprensión de textos', description: 'Ejercicios para desarrollar la comprensión lectora mediante textos cortos y preguntas de análisis.', type: ModuleType.reading, grade: 2, exerciseCount: 3, createdAt: DateTime(2024, 1, 15)),
    ModuleEntity(id: 'mod-lec-2', title: 'Vocabulario y sinónimos', description: 'Actividades para ampliar el vocabulario e identificar sinónimos y antónimos en contexto.', type: ModuleType.reading, grade: 3, exerciseCount: 2, createdAt: DateTime(2024, 1, 20)),
    ModuleEntity(id: 'mod-lec-3', title: 'Inferencia lectora', description: 'Ejercicios para desarrollar la capacidad de inferir información implícita en textos.', type: ModuleType.reading, grade: 4, exerciseCount: 0, createdAt: DateTime(2024, 2, 1)),
    ModuleEntity(id: 'mod-lec-4', title: 'Textos informativos', description: 'Comprensión de textos expositivos y noticias adaptadas al nivel.', type: ModuleType.reading, grade: 5, exerciseCount: 0, createdAt: DateTime(2024, 2, 10)),
    ModuleEntity(id: 'mod-lec-5', title: 'Literatura infantil', description: 'Análisis de cuentos, fábulas y poemas para desarrollar el gusto por la lectura.', type: ModuleType.reading, grade: 6, exerciseCount: 0, createdAt: DateTime(2024, 2, 15)),
    ModuleEntity(id: 'mod-esc-1', title: 'Ortografía básica', description: 'Práctica de reglas ortográficas fundamentales: uso de mayúsculas, puntuación y acento.', type: ModuleType.writing, grade: 2, exerciseCount: 3, createdAt: DateTime(2024, 1, 18)),
    ModuleEntity(id: 'mod-esc-2', title: 'Construcción de oraciones', description: 'Ejercicios para ordenar palabras y construir oraciones con sentido completo.', type: ModuleType.writing, grade: 3, exerciseCount: 2, createdAt: DateTime(2024, 1, 25)),
    ModuleEntity(id: 'mod-esc-3', title: 'Redacción de párrafos', description: 'Práctica de escritura estructurada con ideas principales y secundarias.', type: ModuleType.writing, grade: 4, exerciseCount: 0, createdAt: DateTime(2024, 2, 5)),
    ModuleEntity(id: 'mod-esc-4', title: 'Conectores y coherencia', description: 'Uso de conectores textuales para mejorar la cohesión en los escritos.', type: ModuleType.writing, grade: 5, exerciseCount: 0, createdAt: DateTime(2024, 2, 12)),
    ModuleEntity(id: 'mod-esc-5', title: 'Textos creativos', description: 'Escritura libre y creativa: cuentos cortos, poemas y descripciones.', type: ModuleType.writing, grade: 6, exerciseCount: 0, createdAt: DateTime(2024, 2, 18)),
  ];

  final List<ExerciseEntity> _exercises = [
    // ── Módulo: Comprensión de textos (grado 2) ───────────────────
    // passage: fragmento compartido por ej-001 y ej-002 (comprensión del mismo texto)
    ExerciseEntity(
      id: 'ej-001', moduleId: 'mod-lec-1',
      title: '¿De qué trata el cuento?',
      instructions: 'Lee el siguiente fragmento y responde la pregunta.',
      type: ExerciseType.multipleChoice, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'passage': 'Lucía se despertó muy temprano esa mañana. Se lavó la cara, desayunó su cereal favorito y tomó su mochila colorida. Estaba muy emocionada porque era el primer día de clases.',
        'question': '¿Qué hizo Lucía después de desayunar?',
        'options': ['Se fue a dormir', 'Tomó su mochila y fue a la escuela', 'Llamó a su mamá', 'Jugó en el jardín'],
        'correctIndex': 1,
        'explanation': 'El texto dice que Lucía tomó su mochila colorida, lo que indica que se fue a la escuela.',
      },
    ),
    ExerciseEntity(
      id: 'ej-002', moduleId: 'mod-lec-1',
      title: '¿Verdadero o falso?',
      instructions: 'Lee la afirmación y decide si es verdadera o falsa.',
      type: ExerciseType.trueOrFalse, difficulty: DifficultyLevel.basic, subject: Subject.socialStudies,
      content: {
        'passage': 'Lucía se despertó muy temprano esa mañana. Se lavó la cara, desayunó su cereal favorito y tomó su mochila colorida. Estaba muy emocionada porque era el primer día de clases.',
        'statement': 'Lucía estaba emocionada porque era el primer día de clases.',
        'correctAnswer': true,
        'explanation': 'El texto dice claramente que Lucía estaba muy emocionada porque era el primer día de clases.',
      },
    ),
    ExerciseEntity(
      id: 'ej-003', moduleId: 'mod-lec-1',
      title: 'Completa la oración',
      instructions: 'Escribe la palabra que falta en el espacio.',
      type: ExerciseType.fillInTheBlank, difficulty: DifficultyLevel.intermediate, subject: Subject.science,
      content: {
        'template': 'Lucía caminó hacia la [BLANK] después de desayunar.',
        'correctAnswer': 'escuela',
        'hint': 'Es el lugar donde los niños van a aprender.',
      },
    ),

    // ── Módulo: Vocabulario y sinónimos (grado 3) ─────────────────
    ExerciseEntity(
      id: 'ej-004', moduleId: 'mod-lec-2',
      title: 'Sinónimo de "alegre"',
      instructions: 'Selecciona el sinónimo correcto.',
      type: ExerciseType.multipleChoice, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'question': '¿Cuál es el sinónimo de "alegre"?',
        'options': ['Triste', 'Contento', 'Enojado', 'Cansado'],
        'correctIndex': 1,
        'explanation': 'Contento significa lo mismo que alegre — ambas palabras expresan felicidad.',
      },
    ),
    ExerciseEntity(
      id: 'ej-005', moduleId: 'mod-lec-2',
      title: '"Rápido" y "veloz"',
      instructions: 'Determina si las palabras son sinónimas.',
      type: ExerciseType.trueOrFalse, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'statement': '"Rápido" y "veloz" son sinónimos.',
        'correctAnswer': true,
        'explanation': 'Sí, ambas palabras significan que algo se mueve con mucha velocidad.',
      },
    ),

    // ── Módulo: Ortografía básica (grado 2) ───────────────────────
    ExerciseEntity(
      id: 'ej-006', moduleId: 'mod-esc-1',
      title: 'Mayúscula al inicio',
      instructions: 'Completa la oración con la forma correcta.',
      type: ExerciseType.fillInTheBlank, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'template': '[BLANK] niños juegan en el parque.',
        'correctAnswer': 'Los',
        'hint': 'Recuerda que las oraciones comienzan con mayúscula.',
      },
    ),
    ExerciseEntity(
      id: 'ej-007', moduleId: 'mod-esc-1',
      title: '¿Lleva punto final?',
      instructions: 'Decide si la oración necesita punto final.',
      type: ExerciseType.trueOrFalse, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'statement': 'La oración "El perro corre por el jardín" lleva punto final.',
        'correctAnswer': true,
        'explanation': 'Toda oración que termina una idea debe llevar punto final.',
      },
    ),
    ExerciseEntity(
      id: 'ej-008', moduleId: 'mod-esc-1',
      title: 'Orden de la oración',
      instructions: 'Selecciona el orden correcto de las palabras.',
      type: ExerciseType.multipleChoice, difficulty: DifficultyLevel.intermediate, subject: Subject.spanish,
      content: {
        'question': '¿Cuál es el orden correcto?',
        'options': [
          'parque el en juegan niños Los',
          'Los niños juegan en el parque',
          'juegan Los niños parque el en',
          'en Los niños el juegan parque',
        ],
        'correctIndex': 1,
        'explanation': 'En español el orden correcto es: sujeto (Los niños) + verbo (juegan) + complemento (en el parque).',
      },
    ),

    // ── Módulo: Construcción de oraciones (grado 3) ───────────────
    ExerciseEntity(
      id: 'ej-009', moduleId: 'mod-esc-2',
      title: 'Construye la oración',
      instructions: 'Completa con la palabra adecuada.',
      type: ExerciseType.fillInTheBlank, difficulty: DifficultyLevel.basic, subject: Subject.spanish,
      content: {
        'template': 'El [BLANK] vuela muy alto en el cielo.',
        'correctAnswer': 'pájaro',
        'hint': 'Es un animal con alas y plumas.',
      },
    ),
    ExerciseEntity(
      id: 'ej-010', moduleId: 'mod-esc-2',
      title: 'Sujeto y predicado',
      instructions: 'Determina si la afirmación es correcta.',
      type: ExerciseType.trueOrFalse, difficulty: DifficultyLevel.intermediate, subject: Subject.spanish,
      content: {
        'statement': 'En "La mariposa vuela", "La mariposa" es el sujeto.',
        'correctAnswer': true,
        'explanation': 'El sujeto es quien realiza la acción. En esta oración, "La mariposa" es quien vuela.',
      },
    ),
  ];
}*/