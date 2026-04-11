const mongoose = require('mongoose');
const Resultado = require('../models/resultadoModel');
const Estudiante = require('../models/studentModel');
const Evaluacion = require('../models/evaluacionModel');
const Gamificacion = require('../models/gamificacionModel');
const { registrarLog } = require('../utils/helpers');

// RF-17: Reporte individual
const obtenerReporteIndividual = async (req, res) => {
  try {
    const { estudianteId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(estudianteId)) {
      return res.status(400).json({
        mensaje: 'ID de estudiante inválido'
      });
    }

    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({
        mensaje: 'Estudiante no encontrado'
      });
    }

    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('evaluacion_id', 'titulo')
      .sort({ fecha: 1 });

    const totalEvaluaciones = resultados.length;
    const promedio = totalEvaluaciones > 0
      ? Math.round(resultados.reduce((acc, r) => acc + r.puntuacion, 0) / totalEvaluaciones)
      : 0;

    res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado
      },
      resumen: {
        totalEvaluaciones,
        promedio
      },
      resultados
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener el reporte individual',
      error: error.message
    });
  }
};

// RF-18: Reporte por grado
const obtenerReportePorGrado = async (req, res) => {
  try {
    const { grado } = req.params;

    const estudiantes = await Estudiante.find({ grado: Number(grado) });

    if (estudiantes.length === 0) {
      return res.status(404).json({
        mensaje: 'No hay estudiantes para ese grado'
      });
    }

    const idsEstudiantes = estudiantes.map(e => e._id);

    const resultados = await Resultado.find({
      estudiante_id: { $in: idsEstudiantes }
    })
      .populate('estudiante_id', 'nombre grado')
      .populate('evaluacion_id', 'titulo')
      .sort({ fecha: 1 });

    const promedioGrado = resultados.length > 0
      ? Math.round(resultados.reduce((acc, r) => acc + r.puntuacion, 0) / resultados.length)
      : 0;

    res.status(200).json({
      grado: Number(grado),
      totalEstudiantes: estudiantes.length,
      totalResultados: resultados.length,
      promedioGrado,
      resultados
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener el reporte por grado',
      error: error.message
    });
  }
};

// RF-16: Datos para gráficas de progreso
const obtenerProgresoGraficas = async (req, res) => {
  try {
    const { estudianteId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(estudianteId)) {
      return res.status(400).json({
        mensaje: 'ID de estudiante inválido'
      });
    }

    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({
        mensaje: 'Estudiante no encontrado'
      });
    }

    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('evaluacion_id', 'titulo')
      .sort({ fecha: 1 });

    const labels = resultados.map((r, index) =>
      r.evaluacion_id?.titulo || `Evaluación ${index + 1}`
    );

    const data = resultados.map(r => r.puntuacion);

    res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado
      },
      grafica: {
        labels,
        data
      },
      resultados
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener datos de progreso para gráficas',
      error: error.message
    });
  }
};

// ─────────────────────────────────────────────────────────
// RF-36 + RF-37: Obtener instrucciones y tiempo de evaluación
// ─────────────────────────────────────────────────────────
const obtenerInstruccionesEvaluacion = async (req, res) => {
  try {
    const { evaluacion_id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(evaluacion_id)) {
      return res.status(400).json({
        mensaje: 'ID de evaluación inválido'
      });
    }

    const evaluacion = await Evaluacion.findById(evaluacion_id)
      .select('titulo instrucciones tiempo_limite intentos_max activa creado_en');

    if (!evaluacion) {
      return res.status(404).json({
        mensaje: 'Evaluación no encontrada'
      });
    }

    if (!evaluacion.activa) {
      return res.status(403).json({
        mensaje: 'Esta evaluación no está activa'
      });
    }

    // RF-36: Devolver instrucciones
    // RF-37: Devolver tiempo límite (el frontend hará cuenta regresiva)
    res.status(200).json({
      mensaje: 'Instrucciones y datos de la evaluación',
      evaluacion: {
        id: evaluacion._id,
        titulo: evaluacion.titulo,
        instrucciones: evaluacion.instrucciones || 'No hay instrucciones especiales',
        tiempo_limite: evaluacion.tiempo_limite, // en minutos
        intentos_max: evaluacion.intentos_max,
        timestamp_inicio: new Date() // Para que el frontend calcule el tiempo
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener instrucciones de la evaluación',
      error: error.message
    });
  }
};

// ─────────────────────────────────────────────────────────
// RF-41: Historial de evaluaciones realizadas
// ─────────────────────────────────────────────────────────
const obtenerHistorialEvaluaciones = async (req, res) => {
  try {
    const { estudiante_id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(estudiante_id)) {
      return res.status(400).json({
        mensaje: 'ID de estudiante inválido'
      });
    }

    const estudiante = await Estudiante.findById(estudiante_id);
    if (!estudiante) {
      return res.status(404).json({
        mensaje: 'Estudiante no encontrado'
      });
    }

    // Obtener todos los resultados del estudiante
    const resultados = await Resultado.find({ estudiante_id })
      .populate('evaluacion_id', 'titulo materia_id')
      .populate('evaluacion_id.materia_id', 'nombre')
      .sort({ fecha: -1 })
      .lean();

    if (resultados.length === 0) {
      return res.status(200).json({
        mensaje: 'El estudiante no ha realizado evaluaciones aún',
        estudiante: {
          id: estudiante._id,
          nombre: estudiante.nombre,
          grado: estudiante.grado
        },
        historial: []
      });
    }

    // Procesar el historial
    const historial = resultados.map(resultado => ({
      resultado_id: resultado._id,
      evaluacion_id: resultado.evaluacion_id._id,
      evaluacion_nombre: resultado.evaluacion_id.titulo,
      materia: resultado.evaluacion_id.materia_id?.nombre || 'No especificada',
      puntuacion: resultado.puntuacion,
      preguntas_correctas: resultado.preguntas_correctas,
      total_preguntas: resultado.total_preguntas,
      intento: resultado.intentos,
      fecha: resultado.fecha,
      aprobado: resultado.puntuacion >= 70
    }));

    // Calcular estadísticas
    const promedioGeneral = Math.round(
      resultados.reduce((sum, r) => sum + r.puntuacion, 0) / resultados.length
    );

    const evaluacionesAprobadas = historial.filter(h => h.aprobado).length;

    res.status(200).json({
      mensaje: 'Historial de evaluaciones',
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado
      },
      estadisticas: {
        total_evaluaciones: historial.length,
        evaluaciones_aprobadas: evaluacionesAprobadas,
        promedio_general: promedioGeneral
      },
      historial
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener historial de evaluaciones',
      error: error.message
    });
  }
};

// ─────────────────────────────────────────────────────────
// RF-44: Reiniciar puntuaciones de estudiantes
// Solo docentes y admins pueden hacerlo
// ─────────────────────────────────────────────────────────
const reiniciarPuntuacionesEstudiante = async (req, res) => {
  try {
    const { estudiante_id } = req.params;
    const { tipo_reinicio } = req.body; // 'completo', 'por_evaluacion' o 'por_materia'

    // Validar que sea docente o admin
    if (!req.usuario || (req.usuario.rol !== 'docente' && req.usuario.rol !== 'admin')) {
      return res.status(403).json({
        mensaje: 'Solo docentes o administradores pueden reiniciar puntuaciones'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(estudiante_id)) {
      return res.status(400).json({
        mensaje: 'ID de estudiante inválido'
      });
    }

    if (typeof tipo_reinicio !== 'string' || !['completo', 'por_evaluacion', 'por_materia'].includes(tipo_reinicio)) {
      return res.status(400).json({
        mensaje: 'tipo_reinicio debe ser: completo, por_evaluacion o por_materia'
      });
    }

    const estudiante = await Estudiante.findById(estudiante_id);
    if (!estudiante) {
      return res.status(404).json({
        mensaje: 'Estudiante no encontrado'
      });
    }

    let accion = '';

    // Opción 1: Reinicio completo (elimina todos los resultados)
    if (tipo_reinicio === 'completo') {
      await Resultado.deleteMany({ estudiante_id });
      
      // Reiniciar gamificación
      await Gamificacion.findOneAndUpdate(
        { estudiante_id },
        { 
          puntos_total: 0, 
          nivel: 1, 
          insignias: [],
          actualizado_en: new Date()
        },
        { upsert: true }
      );

      accion = `Reinició completamente los puntos del estudiante ${estudiante.nombre}`;
    }

    // Opción 2: Reinicio por tipo de evaluación (si viene en body)
    else if (tipo_reinicio === 'por_evaluacion' && req.body.evaluacion_id) {
      if (!mongoose.Types.ObjectId.isValid(req.body.evaluacion_id)) {
        return res.status(400).json({
          mensaje: 'evaluacion_id inválido'
        });
      }

      const resultadosEliminados = await Resultado.deleteMany({
        estudiante_id,
        evaluacion_id: req.body.evaluacion_id
      });

      accion = `Reinició puntos para evaluación específica del estudiante ${estudiante.nombre} (${resultadosEliminados.deletedCount} registros)`;
    }

    // Opción 3: Reinicio por materia (si viene en body)
    else if (tipo_reinicio === 'por_materia' && req.body.materia_id) {
      if (!mongoose.Types.ObjectId.isValid(req.body.materia_id)) {
        return res.status(400).json({
          mensaje: 'materia_id inválido'
        });
      }

      // Obtener todas las evaluaciones de esa materia
      const evaluacionesMateria = await Evaluacion.find({ materia_id: req.body.materia_id }).select('_id');
      const idsEvaluaciones = evaluacionesMateria.map(e => e._id);

      const resultadosEliminados = await Resultado.deleteMany({
        estudiante_id,
        evaluacion_id: { $in: idsEvaluaciones }
      });

      accion = `Reinició puntos por materia del estudiante ${estudiante.nombre} (${resultadosEliminados.deletedCount} registros)`;
    }

    // RF-26: Registrar la acción en el log
    if (req.usuario && req.usuario.id) {
      await registrarLog(req.usuario.id, accion);
    }

    // Obtener gamificación actualizada
    const gamificacionActualizada = await Gamificacion.findOne({ estudiante_id });

    res.status(200).json({
      mensaje: 'Puntuaciones reiniciadas correctamente',
      accion,
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre
      },
      gamificacion_actualizada: gamificacionActualizada || {
        puntos_total: 0,
        nivel: 1,
        insignias: []
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al reiniciar puntuaciones',
      error: error.message
    });
  }
};

module.exports = {
  obtenerReporteIndividual,
  obtenerReportePorGrado,
  obtenerProgresoGraficas,
  obtenerInstruccionesEvaluacion,
  obtenerHistorialEvaluaciones,
  reiniciarPuntuacionesEstudiante
};