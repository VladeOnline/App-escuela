const mongoose = require('mongoose');
const Ejercicio = require('../models/ejercicioModel');
const Resultado = require('../models/resultadoModel');
const Evaluacion = require('../models/evaluacionModel');
const Respuesta = require('../models/respuestamodel'); // modelo nuevo

// ---------------------------------------------
// RF-10: El docente crea un ejercicio
// ---------------------------------------------
const crearEjercicio = async (req, res) => {
  try {
    const { contenido_id, evaluacion_id, pregunta, opciones, respuesta_correcta, dificultad } = req.body;

    // RF-29: validar campos obligatorios
    if (!contenido_id || !evaluacion_id || !pregunta || !respuesta_correcta || !dificultad) {
      return res.status(400).json({
        mensaje: 'Faltan campos obligatorios: contenido_id, evaluacion_id, pregunta, respuesta_correcta, dificultad'
      });
    }

    // Validar IDs de Mongo
    if (
      !mongoose.Types.ObjectId.isValid(contenido_id) ||
      !mongoose.Types.ObjectId.isValid(evaluacion_id)
    ) {
      return res.status(400).json({
        mensaje: 'contenido_id o evaluacion_id no tienen un formato válido'
      });
    }

    // Validar texto vacío
    if (
      pregunta.trim() === '' ||
      respuesta_correcta.trim() === '' ||
      dificultad.trim() === ''
    ) {
      return res.status(400).json({
        mensaje: 'Pregunta, respuesta_correcta y dificultad no pueden ir vacíos'
      });
    }

    // RF-11: validar dificultad
    const dificultadesValidas = ['facil', 'medio', 'dificil'];
    if (!dificultadesValidas.includes(dificultad.trim().toLowerCase())) {
      return res.status(400).json({
        mensaje: 'La dificultad debe ser: facil, medio o dificil'
      });
    }

    // RF-29: validar opciones si vienen
    if (opciones && !Array.isArray(opciones)) {
      return res.status(400).json({
        mensaje: 'El campo opciones debe ser un arreglo'
      });
    }

    if (opciones && opciones.length > 0) {
      const opcionesLimpias = opciones.map(op => op.trim()).filter(op => op !== '');

      if (opcionesLimpias.length < 2) {
        return res.status(400).json({
          mensaje: 'Debe haber al menos 2 opciones válidas'
        });
      }

      if (!opcionesLimpias.includes(respuesta_correcta.trim())) {
        return res.status(400).json({
          mensaje: 'La respuesta correcta debe estar dentro de las opciones'
        });
      }
    }

    const evaluacion = await Evaluacion.findById(evaluacion_id);
    if (!evaluacion) {
      return res.status(404).json({
        mensaje: 'La evaluación indicada no existe'
      });
    }

    const nuevoEjercicio = new Ejercicio({
      contenido_id,
      evaluacion_id,
      pregunta: pregunta.trim(),
      opciones: opciones ? opciones.map(op => op.trim()) : [],
      respuesta_correcta: respuesta_correcta.trim(),
      dificultad: dificultad.trim().toLowerCase(),
      activo: true
    });

    const ejercicioGuardado = await nuevoEjercicio.save();

    res.status(201).json({
      mensaje: 'Ejercicio creado exitosamente',
      ejercicio: ejercicioGuardado
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear el ejercicio',
      error: error.message
    });
  }
};
// RF-12: Activar o desactivar ejercicio
const cambiarEstadoEjercicio = async (req, res) => {
  try {
    const { id } = req.params;
    const { activo } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de ejercicio inválido'
      });
    }

    if (typeof activo !== 'boolean') {
      return res.status(400).json({
        mensaje: 'El campo activo debe ser true o false'
      });
    }

    const ejercicioActualizado = await Ejercicio.findByIdAndUpdate(
      id,
      { activo },
      { new: true }
    );

    if (!ejercicioActualizado) {
      return res.status(404).json({
        mensaje: 'Ejercicio no encontrado'
      });
    }

    res.status(200).json({
      mensaje: activo
        ? 'Ejercicio activado correctamente'
        : 'Ejercicio desactivado correctamente',
      ejercicio: ejercicioActualizado
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al cambiar el estado del ejercicio',
      error: error.message
    });
  }
};
const obtenerEjercicios = async (req, res) => {
  try {
    const ejercicios = await Ejercicio.find()
      .populate('contenido_id')
      .populate('evaluacion_id');

    res.status(200).json({
      total: ejercicios.length,
      ejercicios
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener ejercicios',
      error: error.message
    });
  }
};
// ---------------------------------------------
// RF-13 + RF-14 (PASO 1): El estudiante responde UNA pregunta
//
// AHORA sí guarda la respuesta en la BD.
// Flutter sigue recibiendo si fue correcta o no para mostrar el âœ… o âŒ,
// pero ya no necesitamos confiar en lo que Flutter nos diga al finalizar.
// ---------------------------------------------
const responderPregunta = async (req, res) => {
  try {
    // Ahora necesitamos también estudiante_id y evaluacion_id para guardar la respuesta
    const { estudiante_id, evaluacion_id, ejercicio_id, respuesta_dada } = req.body;

    // Validamos que lleguen todos los campos
    if (!estudiante_id || !evaluacion_id || !ejercicio_id || !respuesta_dada) {
      return res.status(400).json({
        mensaje: 'Faltan campos: estudiante_id, evaluacion_id, ejercicio_id, respuesta_dada'
      });
    }

    // Buscamos el ejercicio para obtener la respuesta correcta
    const ejercicio = await Ejercicio.findById(ejercicio_id);
    if (!ejercicio) {
      return res.status(404).json({ mensaje: 'Ejercicio no encontrado' });
    }
    if (!ejercicio.activo) {
      return res.status(403).json({ mensaje: 'Este ejercicio no está activo' });
    }

    // Verificamos que el ejercicio pertenece a la evaluación indicada
    // Esto evita que alguien mande un ejercicio de otra evaluación
    if (ejercicio.evaluacion_id.toString() !== evaluacion_id) {
      return res.status(400).json({ mensaje: 'Este ejercicio no pertenece a esa evaluación' });
    }

    // Verificamos que este estudiante no haya respondido ya este ejercicio
    // en este intento â€” evitamos respuestas duplicadas
    const yaRespondio = await Respuesta.findOne({ estudiante_id, evaluacion_id, ejercicio_id });
    if (yaRespondio) {
      return res.status(400).json({ mensaje: 'Ya respondiste este ejercicio en esta evaluación' });
    }

    // -- RF-14: Comparamos la respuesta con la correcta --
    const esCorrecta = respuesta_dada.trim().toLowerCase() === ejercicio.respuesta_correcta.trim().toLowerCase();

    // Calculamos los puntos según dificultad
    let puntosObtenidos = 0;
    if (esCorrecta) {
      if (ejercicio.dificultad === 'facil')   puntosObtenidos = 10;
      if (ejercicio.dificultad === 'medio')   puntosObtenidos = 20;
      if (ejercicio.dificultad === 'dificil') puntosObtenidos = 30;
    }

    // -- RF-13: Guardamos la respuesta en la BD --
    // Ahora sí tenemos un registro real de lo que respondió el estudiante
    const nuevaRespuesta = new Respuesta({
      estudiante_id,
      evaluacion_id,
      ejercicio_id,
      respuesta_dada,
      es_correcta: esCorrecta,       // el backend decide esto, no Flutter
      puntos_obtenidos: puntosObtenidos
    });

    await nuevaRespuesta.save();

    // Respondemos a Flutter para que muestre el âœ… o âŒ
    res.status(201).json({
      esCorrecta,
      puntosObtenidos,
      respuestaCorrecta: esCorrecta ? null : ejercicio.respuesta_correcta
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar la respuesta', error: error.message });
  }
};

// ---------------------------------------------
// RF-13 + RF-14 (PASO 2): Finalizar la evaluación
//
// Ya NO recibe respuestasCorrectas desde Flutter.
// El backend busca en la BD todas las respuestas guardadas
// y calcula la nota él solo. Flutter no puede mentir.
// ---------------------------------------------
const finalizarEvaluacion = async (req, res) => {
  try {
    const { estudiante_id, evaluacion_id } = req.body;

    if (!estudiante_id || !evaluacion_id) {
      return res.status(400).json({ mensaje: 'Se requieren: estudiante_id y evaluacion_id' });
    }

    // Verificamos que la evaluación existe
    const evaluacion = await Evaluacion.findById(evaluacion_id);
    if (!evaluacion) {
      return res.status(404).json({ mensaje: 'Evaluación no encontrada' });
    }

    // Verificamos el límite de intentos
    const intentosPrevios = await Resultado.countDocuments({ estudiante_id, evaluacion_id });
    if (intentosPrevios >= evaluacion.intentos_max) {
      return res.status(403).json({
        mensaje: `Ya usaste todos los intentos permitidos (${evaluacion.intentos_max})`
      });
    }

    // -- Aquí está la clave: el backend busca las respuestas guardadas --
    // Buscamos todas las respuestas que guardó /responder para este estudiante en esta evaluación
    const respuestasGuardadas = await Respuesta.find({ estudiante_id, evaluacion_id });

    // Si no hay ninguna respuesta guardada, el estudiante no respondió nada
    if (respuestasGuardadas.length === 0) {
      return res.status(400).json({ mensaje: 'No hay respuestas registradas para esta evaluación' });
    }

    // Contamos cuántas fueron correctas leyendo los datos reales de la BD
    // .filter() crea un arreglo nuevo solo con los elementos que cumplan la condición
    const correctas = respuestasGuardadas.filter(r => r.es_correcta).length;
    const totalPreguntas = respuestasGuardadas.length;

    // -- RF-14: Calculamos la nota final con datos reales --
    const notaFinal = Math.round((correctas / totalPreguntas) * 100);

    // -- RF-13: Guardamos el resultado final en la BD --
    const nuevoResultado = new Resultado({
      estudiante_id,
      evaluacion_id,
      puntuacion: notaFinal,          // nota calculada por el backend, no por Flutter
      intentos: intentosPrevios + 1,
      fecha: new Date()
    });

    await nuevoResultado.save();

    // Limpiamos las respuestas temporales de este intento
    // Ya no las necesitamos porque el resultado final quedó guardado en 'resultados'
    await Respuesta.deleteMany({ estudiante_id, evaluacion_id });

    // Respondemos con el resumen final
    res.status(201).json({
      mensaje: 'Evaluación finalizada',
      resumen: {
        notaFinal,                             // calculado por el backend
        respuestasCorrectas: correctas,        // contado por el backend
        totalPreguntas,                        // contado por el backend
        intento: intentosPrevios + 1,
        intentosRestantes: evaluacion.intentos_max - (intentosPrevios + 1),
        aprobado: notaFinal >= 70              // 70 es la nota mínima en Costa Rica
      }
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al finalizar la evaluación', error: error.message });
  }
};

// ---------------------------------------------
// Extra: El docente consulta los resultados de una evaluación
// ---------------------------------------------
const obtenerResultadosPorEvaluacion = async (req, res) => {
  try {
    const { id } = req.params;

    const resultados = await Resultado.find({ evaluacion_id: id })
      .populate('estudiante_id', 'nombre grado');

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
  cambiarEstadoEjercicio,
  obtenerEjercicios,
  responderPregunta,
  finalizarEvaluacion,
  obtenerResultadosPorEvaluacion

};
