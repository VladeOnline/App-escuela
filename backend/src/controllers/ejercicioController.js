const mongoose = require('mongoose');
const Ejercicio = require('../models/ejercicioModel');
const Resultado = require('../models/resultadoModel');
const Gamificacion = require('../models/gamificacionModel');
const { registrarLog } = require('../utils/helpers');

// ─────────────────────────────────────────────
// Función auxiliar: calcula los puntos según dificultad
// Se usa en crearEjercicio y en responderEjercicio
// ─────────────────────────────────────────────
const calcularPuntos = (dificultad) => {
  if (dificultad === 'basico')     return 10;
  if (dificultad === 'intermedio') return 20;
  if (dificultad === 'avanzado')   return 30;
  return 0;
};

// ─────────────────────────────────────────────
// Función auxiliar: valida el campo content según el tipo de ejercicio
// Devuelve un mensaje de error si algo falta, o null si todo está bien
// ─────────────────────────────────────────────
const validarContent = (tipo, content) => {
  if (!content || typeof content !== 'object') {
    return 'El campo content es obligatorio';
  }

  switch (tipo) {
    case 'seleccion_multiple':
      // Necesita: question (string), options (array de al menos 2), correctIndex (número)
      if (!content.question || content.question.trim() === '') return 'seleccion_multiple requiere el campo question';
      if (!Array.isArray(content.options) || content.options.length < 2) return 'seleccion_multiple requiere al menos 2 opciones en options';
      if (typeof content.correctIndex !== 'number') return 'seleccion_multiple requiere correctIndex (número)';
      if (content.correctIndex < 0 || content.correctIndex >= content.options.length) return 'correctIndex está fuera del rango de opciones';
      break;

    case 'verdadero_falso':
      // Necesita: statement (string), correctAnswer (boolean)
      if (!content.statement || content.statement.trim() === '') return 'verdadero_falso requiere el campo statement';
      if (typeof content.correctAnswer !== 'boolean') return 'verdadero_falso requiere correctAnswer (true o false)';
      break;

    case 'completar_espacio':
      // Necesita: template con [BLANK], correctAnswer (string)
      if (!content.template || !content.template.includes('[BLANK]')) return 'completar_espacio requiere template con la marca [BLANK]';
      if (!content.correctAnswer || content.correctAnswer.trim() === '') return 'completar_espacio requiere correctAnswer';
      break;

    case 'ordenamiento':
      // Necesita: words (array), correctOrder (array de igual longitud)
      if (!Array.isArray(content.words) || content.words.length < 2) return 'ordenamiento requiere al menos 2 palabras en words';
      if (!Array.isArray(content.correctOrder) || content.correctOrder.length !== content.words.length) return 'correctOrder debe tener la misma cantidad de elementos que words';
      break;

    default:
      return 'Tipo de ejercicio no reconocido';
  }

  return null; // null = sin errores
};

// ─────────────────────────────────────────────
// Función auxiliar: verifica si la respuesta del estudiante es correcta
// Según el tipo de ejercicio, la comparación es diferente
// ─────────────────────────────────────────────
const verificarRespuesta = (tipo, content, respuestaDada) => {
  switch (tipo) {
    case 'seleccion_multiple':
      // respuestaDada debe ser el índice de la opción seleccionada (número)
      return Number(respuestaDada) === content.correctIndex;

    case 'verdadero_falso':
      // respuestaDada debe ser 'true' o 'false' como string
      return respuestaDada.toString() === content.correctAnswer.toString();

    case 'completar_espacio':
      // Comparación sin importar mayúsculas ni espacios
      return respuestaDada.trim().toLowerCase() === content.correctAnswer.trim().toLowerCase();

    case 'ordenamiento':
      // respuestaDada debe ser un array de índices en el orden que eligió el estudiante
      if (!Array.isArray(respuestaDada)) return false;
      return JSON.stringify(respuestaDada) === JSON.stringify(content.correctOrder);

    default:
      return false;
  }
};

// ─────────────────────────────────────────────
// RF-10: El docente crea un ejercicio nuevo
// POST /api/ejercicios
// ─────────────────────────────────────────────
const crearEjercicio = async (req, res) => {
  try {
    const { contenido_id, titulo, instrucciones, tipo, dificultad, materia, tiempo_limite, intentos_max, content } = req.body;

    // Validar campos obligatorios
    if (!contenido_id || !titulo || !instrucciones || !tipo || !dificultad || !materia || !content) {
      return res.status(400).json({
        mensaje: 'Faltan campos obligatorios: contenido_id, titulo, instrucciones, tipo, dificultad, materia, content'
      });
    }

    // Validar que el contenido_id sea un ObjectId válido de MongoDB
    if (!mongoose.Types.ObjectId.isValid(contenido_id)) {
      return res.status(400).json({ mensaje: 'contenido_id no tiene un formato válido' });
    }

    // Validar que tipo y dificultad tengan valores permitidos
    const tiposValidos = ['seleccion_multiple', 'verdadero_falso', 'completar_espacio', 'ordenamiento'];
    if (!tiposValidos.includes(tipo)) {
      return res.status(400).json({ mensaje: 'tipo debe ser: seleccion_multiple, verdadero_falso, completar_espacio u ordenamiento' });
    }

    const dificultadesValidas = ['basico', 'intermedio', 'avanzado'];
    if (!dificultadesValidas.includes(dificultad)) {
      return res.status(400).json({ mensaje: 'dificultad debe ser: basico, intermedio o avanzado' });
    }

    const materiasValidas = ['español', 'matematicas', 'ciencias', 'estudios_sociales'];
    if (!materiasValidas.includes(materia)) {
      return res.status(400).json({ mensaje: 'materia debe ser: español, matematicas, ciencias o estudios_sociales' });
    }

    // Validar el campo content según el tipo de ejercicio
    const errorContent = validarContent(tipo, content);
    if (errorContent) {
      return res.status(400).json({ mensaje: errorContent });
    }

    // Calcular puntos automáticamente según la dificultad
    const puntos = calcularPuntos(dificultad);

    // Crear y guardar el ejercicio
    const nuevoEjercicio = new Ejercicio({
      contenido_id,
      titulo: titulo.trim(),
      instrucciones: instrucciones.trim(),
      tipo,
      dificultad,
      materia,
      puntos,                          // calculado automáticamente
      tiempo_limite: tiempo_limite || 5,
      intentos_max: intentos_max || 3,
      content,
      activo: true
    });

    const ejercicioGuardado = await nuevoEjercicio.save();

    // RF-26: Registrar acción del docente en el log
    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Creó ejercicio: "${titulo.trim()}" en contenido ${contenido_id}`);
    }

    res.status(201).json({
      mensaje: 'Ejercicio creado exitosamente',
      ejercicio: ejercicioGuardado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al crear el ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener ejercicios de un contenido específico
// GET /api/ejercicios?contenido_id=xxx
// El frontend llama esto cuando el docente abre un módulo/contenido
// ─────────────────────────────────────────────
const obtenerEjercicios = async (req, res) => {
  try {
    const { contenido_id } = req.query;

    // Si viene contenido_id filtramos por ese contenido
    // Si no viene, devolvemos todos (útil para admin)
    const filtro = contenido_id ? { contenido_id } : {};

    const ejercicios = await Ejercicio.find(filtro)
      .populate('contenido_id', 'titulo grado'); // traemos solo título y grado del contenido

    res.status(200).json({
      total: ejercicios.length,
      ejercicios
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener ejercicios', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener un ejercicio por su ID
// GET /api/ejercicios/:id
// El frontend llama esto cuando el estudiante abre un ejercicio específico
// ─────────────────────────────────────────────
const obtenerEjercicioPorId = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    const ejercicio = await Ejercicio.findById(id)
      .populate('contenido_id', 'titulo grado');

    if (!ejercicio) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }

    res.status(200).json({ ejercicio });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener el ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Editar un ejercicio existente
// PUT /api/ejercicios/:id
// ─────────────────────────────────────────────
const editarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;
    const { titulo, instrucciones, tipo, dificultad, materia, tiempo_limite, intentos_max, content } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    // Si cambió la dificultad, recalculamos los puntos
    const actualizacion = {};
    if (titulo)        actualizacion.titulo = titulo.trim();
    if (instrucciones) actualizacion.instrucciones = instrucciones.trim();
    if (tipo)          actualizacion.tipo = tipo;
    if (materia)       actualizacion.materia = materia;
    if (tiempo_limite) actualizacion.tiempo_limite = tiempo_limite;
    if (intentos_max)  actualizacion.intentos_max = intentos_max;
    if (content)       actualizacion.content = content;

    if (dificultad) {
      actualizacion.dificultad = dificultad;
      actualizacion.puntos = calcularPuntos(dificultad); // recalculamos puntos
    }

    // Si viene content nuevo, lo validamos con el tipo actual
    if (content && tipo) {
      const errorContent = validarContent(tipo, content);
      if (errorContent) return res.status(400).json({ mensaje: errorContent });
    }

    const ejercicioActualizado = await Ejercicio.findByIdAndUpdate(
      id,
      actualizacion,
      { new: true } // devuelve el documento ya actualizado
    );

    if (!ejercicioActualizado) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }

    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Editó ejercicio: "${ejercicioActualizado.titulo}"`);
    }

    res.status(200).json({
      mensaje: 'Ejercicio actualizado correctamente',
      ejercicio: ejercicioActualizado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al editar el ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// RF-12: Activar o desactivar un ejercicio
// PATCH /api/ejercicios/:id/toggle
// El docente puede ocultar ejercicios sin eliminarlos
// ─────────────────────────────────────────────
const toggleEjercicio = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    // Buscamos el ejercicio para saber su estado actual
    const ejercicio = await Ejercicio.findById(id);
    if (!ejercicio) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }

    // Invertimos el estado actual: si estaba activo lo desactivamos y viceversa
    ejercicio.activo = !ejercicio.activo;
    await ejercicio.save();

    res.status(200).json({
      mensaje: ejercicio.activo ? 'Ejercicio activado' : 'Ejercicio desactivado',
      id: ejercicio._id,
      activo: ejercicio.activo
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al cambiar estado del ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Activar o desactivar varios ejercicios a la vez
// PATCH /api/ejercicios/bulk-toggle
// El docente selecciona varios y los activa/desactiva juntos
// ─────────────────────────────────────────────
const bulkToggleEjercicios = async (req, res) => {
  try {
    const { ids, activo } = req.body;

    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ mensaje: 'Se requiere un arreglo de ids' });
    }

    if (typeof activo !== 'boolean') {
      return res.status(400).json({ mensaje: 'El campo activo debe ser true o false' });
    }

    // Actualizamos todos los ejercicios del arreglo de una sola vez
    // $in es el operador de MongoDB equivalente al IN de SQL
    const resultado = await Ejercicio.updateMany(
      { _id: { $in: ids } },
      { activo }
    );

    res.status(200).json({
      mensaje: activo ? 'Ejercicios activados' : 'Ejercicios desactivados',
      actualizados: resultado.modifiedCount
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al actualizar ejercicios', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Eliminar un ejercicio
// DELETE /api/ejercicios/:id
// ─────────────────────────────────────────────
const eliminarEjercicio = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    const ejercicio = await Ejercicio.findByIdAndDelete(id);
    if (!ejercicio) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }

    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Eliminó ejercicio: "${ejercicio.titulo}"`);
    }

    res.status(200).json({ mensaje: 'Ejercicio eliminado correctamente' });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar el ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// RF-13 + RF-14 + RF-24: El estudiante responde un ejercicio
// POST /api/ejercicios/:id/responder
//
// Compara la respuesta con la correcta, guarda el resultado
// y devuelve retroalimentación inmediata para que Flutter
// muestre el ✅ o ❌ con los puntos ganados
// ─────────────────────────────────────────────
const responderEjercicio = async (req, res) => {
  try {
    const { id } = req.params;                        // ejercicio_id viene en la URL
    const { estudiante_id, respuesta_dada } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    if (!estudiante_id || respuesta_dada === undefined) {
      return res.status(400).json({ mensaje: 'Se requieren: estudiante_id y respuesta_dada' });
    }

    // Buscamos el ejercicio
    const ejercicio = await Ejercicio.findById(id);
    if (!ejercicio) return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    if (!ejercicio.activo) return res.status(403).json({ mensaje: 'Este ejercicio no está activo' });

    // Verificamos cuántos intentos previos tuvo este estudiante en este ejercicio
    const intentosPrevios = await Resultado.countDocuments({ estudiante_id, ejercicio_id: id });

    // Si ya agotó los intentos, bloqueamos (RF-30)
    if (intentosPrevios >= ejercicio.intentos_max) {
      return res.status(403).json({
        mensaje: `Ya usaste todos los intentos permitidos (${ejercicio.intentos_max})`
      });
    }

    // ── RF-14: Verificamos si la respuesta es correcta ──
    // La función verificarRespuesta sabe cómo comparar según el tipo
    const esCorrecta = verificarRespuesta(ejercicio.tipo, ejercicio.content, respuesta_dada);

    // Los puntos se ganan solo si es correcto
    const puntosObtenidos = esCorrecta ? ejercicio.puntos : 0;

    // ── RF-13: Guardamos el resultado en la BD ──
    const nuevoResultado = new Resultado({
      estudiante_id,
      ejercicio_id: id,
      puntuacion: puntosObtenidos,
      intentos: intentosPrevios + 1,
      es_correcto: esCorrecta,
      fecha: new Date()
    });

    await nuevoResultado.save();

    // ── RF-20: Si acertó, sumamos puntos a la gamificación ──
    if (esCorrecta) {
      await Gamificacion.findOneAndUpdate(
        { estudiante_id },
        {
          $inc: { puntos_total: puntosObtenidos },
          $set: { actualizado_en: new Date() }
        },
        { upsert: true, new: true }
      );
    }

    // ── RF-24: Retroalimentación inmediata para Flutter ──
    res.status(201).json({
      mensaje: esCorrecta ? '¡Respuesta correcta!' : 'Respuesta incorrecta',
      retroalimentacion: {
        esCorrecta,
        puntosObtenidos,
        intento: intentosPrevios + 1,
        intentosRestantes: ejercicio.intentos_max - (intentosPrevios + 1),
        // Si falló le mostramos la respuesta correcta para que aprenda
        respuestaCorrecta: esCorrecta ? null : ejercicio.content.correctAnswer ?? ejercicio.content.correctIndex,
        explicacion: ejercicio.content.explanation ?? null
      }
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar la respuesta', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener resultados de un ejercicio (para el docente)
// GET /api/ejercicios/:id/resultados
// ─────────────────────────────────────────────
const obtenerResultadosPorEjercicio = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de ejercicio inválido' });
    }

    const resultados = await Resultado.find({ ejercicio_id: id })
      .populate('estudiante_id', 'nombre grado')
      .sort({ fecha: -1 }); // más recientes primero

    res.status(200).json({
      total: resultados.length,
      resultados
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener resultados', error: error.message });
  }
};

module.exports = {
  crearEjercicio,
  obtenerEjercicios,
  obtenerEjercicioPorId,
  editarEjercicio,
  toggleEjercicio,
  bulkToggleEjercicios,
  eliminarEjercicio,
  responderEjercicio,
  obtenerResultadosPorEjercicio
};