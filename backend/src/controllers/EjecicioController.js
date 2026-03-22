const Ejercicio = require('../models/ejercicioModel');
const Resultado = require('../models/resultadoModel');
const Evaluacion = require('../models/evaluacionModel');

// ─────────────────────────────────────────────
// RF-10: El docente crea un ejercicio
// Al crearlo, lo vincula a una evaluación específica
// ─────────────────────────────────────────────
const crearEjercicio = async (req, res) => {
  try {
    // Ahora recibimos evaluacion_id además de los campos anteriores
    const { contenido_id, evaluacion_id, pregunta, opciones, respuesta_correcta, dificultad } = req.body;

    // Validamos que no falte ningún campo obligatorio
    if (!contenido_id || !evaluacion_id || !pregunta || !respuesta_correcta || !dificultad) {
      return res.status(400).json({
        mensaje: 'Faltan campos: contenido_id, evaluacion_id, pregunta, respuesta_correcta, dificultad'
      });
    }

    // Verificamos que la evaluación a la que se vincula realmente existe
    const evaluacion = await Evaluacion.findById(evaluacion_id);
    if (!evaluacion) {
      return res.status(404).json({ mensaje: 'La evaluación indicada no existe' });
    }

    // Validamos que la dificultad sea uno de los valores permitidos
    const dificultadesValidas = ['facil', 'medio', 'dificil'];
    if (!dificultadesValidas.includes(dificultad)) {
      return res.status(400).json({ mensaje: 'Dificultad debe ser: facil, medio o dificil' });
    }

    // Creamos y guardamos el ejercicio
    const nuevoEjercicio = new Ejercicio({
      contenido_id,
      evaluacion_id,       // <-- campo nuevo que vincula el ejercicio a su evaluación
      pregunta,
      opciones,
      respuesta_correcta,
      dificultad,
      activo: true
    });

    const ejercicioGuardado = await nuevoEjercicio.save();

    res.status(201).json({
      mensaje: 'Ejercicio creado exitosamente',
      ejercicio: ejercicioGuardado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al crear el ejercicio', error: error.message });
  }
};

// ─────────────────────────────────────────────
// RF-13 + RF-14 (PASO 1 de 2): El estudiante responde UNA pregunta
//
// Este endpoint se llama una vez por cada pregunta, estilo Kahoot.
// Flutter lo llama, recibe si fue correcta o no, y muestra el resultado
// visual al estudiante antes de pasar a la siguiente pregunta.
//
// IMPORTANTE: este endpoint NO guarda en la base de datos todavía.
// Solo calcula y responde. El guardado ocurre al final con /finalizar
// ─────────────────────────────────────────────
const responderPregunta = async (req, res) => {
  try {
    const { ejercicio_id, respuesta_dada } = req.body;

    // Validamos que lleguen los dos datos necesarios
    if (!ejercicio_id || !respuesta_dada) {
      return res.status(400).json({ mensaje: 'Se requieren: ejercicio_id y respuesta_dada' });
    }

    // Buscamos el ejercicio para obtener la respuesta correcta
    const ejercicio = await Ejercicio.findById(ejercicio_id);
    if (!ejercicio) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }
    if (!ejercicio.activo) {
      return res.status(403).json({ mensaje: 'Este ejercicio no está activo' });
    }

    // ── RF-14: Comparamos la respuesta del estudiante con la correcta ──
    // .trim() elimina espacios accidentales
    // .toLowerCase() hace la comparación sin importar mayúsculas
    const esCorrecta = respuesta_dada.trim().toLowerCase() === ejercicio.respuesta_correcta.trim().toLowerCase();

    // Calculamos los puntos que vale esta pregunta según su dificultad
    // Esto lo necesitamos para que Flutter pueda acumular el puntaje del lado del cliente
    // mientras el estudiante avanza pregunta por pregunta
    let puntosPorPregunta = 0;
    if (esCorrecta) {
      if (ejercicio.dificultad === 'facil')   puntosPorPregunta = 10;
      if (ejercicio.dificultad === 'medio')   puntosPorPregunta = 20;
      if (ejercicio.dificultad === 'dificil') puntosPorPregunta = 30;
    }

    // Respondemos inmediatamente para que Flutter muestre el ✅ o ❌
    // NO guardamos nada en la BD todavía, eso es trabajo del endpoint /finalizar
    res.status(200).json({
      esCorrecta,                                          // true o false → Flutter muestra ✅ o ❌
      puntosPorPregunta,                                   // Puntos ganados en esta pregunta
      respuestaCorrecta: esCorrecta ? null : ejercicio.respuesta_correcta // Si falló, muestra cuál era
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al verificar la respuesta', error: error.message });
  }
};

// ─────────────────────────────────────────────
// RF-13 + RF-14 (PASO 2 de 2): Finalizar la evaluación
//
// Flutter llama este endpoint UNA SOLA VEZ al terminar todas las preguntas.
// Recibe un resumen de cuántas respondió bien y calcula la nota final (0-100).
//
// Ejemplo de lo que Flutter manda:
// {
//   estudiante_id: "abc",
//   evaluacion_id: "xyz",
//   respuestasCorrectas: 3,   ← cuántas acertó
//   totalPreguntas: 4         ← cuántas había en total
// }
// ─────────────────────────────────────────────
const finalizarEvaluacion = async (req, res) => {
  try {
    const { estudiante_id, evaluacion_id, respuestasCorrectas, totalPreguntas } = req.body;

    // Validamos que lleguen todos los datos necesarios
    if (!estudiante_id || !evaluacion_id || respuestasCorrectas === undefined || !totalPreguntas) {
      return res.status(400).json({
        mensaje: 'Se requieren: estudiante_id, evaluacion_id, respuestasCorrectas, totalPreguntas'
      });
    }

    // Verificamos que la evaluación existe
    const evaluacion = await Evaluacion.findById(evaluacion_id);
    if (!evaluacion) {
      return res.status(404).json({ mensaje: 'Evaluación no encontrada' });
    }

    // Verificamos cuántos intentos previos tuvo este estudiante en esta evaluación
    // countDocuments cuenta documentos en MongoDB que cumplan el filtro dado
    const intentosPrevios = await Resultado.countDocuments({
      estudiante_id,
      evaluacion_id
    });

    // Si ya llegó al límite de intentos, no dejamos hacer otro intento
    if (intentosPrevios >= evaluacion.intentos_max) {
      return res.status(403).json({
        mensaje: `Ya usaste todos los intentos permitidos (${evaluacion.intentos_max})`
      });
    }

    // ── RF-14: Calculamos la nota final en escala de 0 a 100 ──
    // Fórmula: (correctas / total) * 100
    // Math.round redondea al entero más cercano, ej: 75.5 → 76
    const notaFinal = Math.round((respuestasCorrectas / totalPreguntas) * 100);

    // ── RF-13: Guardamos el resultado final en la base de datos ──
    const nuevoResultado = new Resultado({
      estudiante_id,                  // Quién hizo la evaluación
      evaluacion_id,                  // Qué evaluación fue
      puntuacion: notaFinal,          // Nota final calculada automáticamente (0-100)
      intentos: intentosPrevios + 1,  // Número de intento actual
      fecha: new Date()               // Fecha y hora exacta de finalización
    });

    await nuevoResultado.save();

    // Calculamos cuántos intentos le quedan para informarle al estudiante
    const intentosRestantes = evaluacion.intentos_max - (intentosPrevios + 1);

    // Respondemos con el resumen completo para que Flutter muestre la pantalla final
    res.status(201).json({
      mensaje: 'Evaluación finalizada',
      resumen: {
        notaFinal,                  // Ej: 75 → significa 75/100
        respuestasCorrectas,        // Ej: 3
        totalPreguntas,             // Ej: 4 → el estudiante tuvo 3/4
        intento: intentosPrevios + 1,
        intentosRestantes,
        aprobado: notaFinal >= 70   // En Costa Rica 70 es la nota mínima de aprobación
      }
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al finalizar la evaluación', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Extra: El docente consulta los resultados de una evaluación
// ─────────────────────────────────────────────
const obtenerResultadosPorEvaluacion = async (req, res) => {
  try {
    // El evaluacion_id viene como parámetro en la URL
    // Ejemplo: GET /api/ejercicios/resultados/abc123
    const { id } = req.params;

    // Buscamos todos los resultados y traemos los datos del estudiante con populate()
    // populate() reemplaza el ID por el documento real del estudiante
    const resultados = await Resultado.find({ evaluacion_id: id })
      .populate('estudiante_id', 'nombre grado'); // Solo traemos nombre y grado

    res.status(200).json({
      total: resultados.length,
      resultados
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener resultados', error: error.message });
  }
};

// Exportamos todas las funciones para usarlas en las rutas
module.exports = {
  crearEjercicio,
  responderPregunta,
  finalizarEvaluacion,
  obtenerResultadosPorEvaluacion
};