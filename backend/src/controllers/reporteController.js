const Usuario = require('../models/userModel');
const Estudiante = require('../models/studentModel');
const Resultado = require('../models/resultadoModel');

// RF-17: Reporte individual de un estudiante
const getIndividualReport = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    // Buscar estudiante
    const estudiante = await Estudiante.findById(estudianteId).populate('usuario_id', 'nombre');
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    // Buscar resultados del estudiante
    const resultados = await Resultado.find({ estudiante_id: estudianteId }).populate('evaluacion_id', 'nombre');

    // Calcular resumen
    const totalEvaluaciones = resultados.length;
    const promedio = totalEvaluaciones > 0
      ? Math.round(resultados.reduce((sum, r) => sum + r.puntuacion, 0) / totalEvaluaciones)
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
      resultados: resultados.map(r => ({
        evaluacionId: r.evaluacion_id._id,
        evaluacionNombre: r.evaluacion_id.nombre,
        puntuacion: r.puntuacion,
        intento: r.intentos,
        fecha: r.fecha
      }))
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener reporte', error: error.message });
  }
};

// RF-18: Reporte por grado (comparativa)
const getGradeReport = async (req, res) => {
  try {
    const { grado } = req.params;

    // Obtener todos los estudiantes del grado
    const estudiantes = await Estudiante.find({ grado: parseInt(grado) });
    
    if (estudiantes.length === 0) {
      return res.status(404).json({ mensaje: 'No hay estudiantes para ese grado' });
    }

    // Calcular promedio por estudiante
    const reportePorEstudiante = await Promise.all(
      estudiantes.map(async (est) => {
        const resultados = await Resultado.find({ estudiante_id: est._id });
        const promedio = resultados.length > 0
          ? Math.round(resultados.reduce((sum, r) => sum + r.puntuacion, 0) / resultados.length)
          : 0;
        return {
          estudianteId: est._id,
          estudianteNombre: est.nombre,
          promedio,
          totalEvaluaciones: resultados.length
        };
      })
    );

    // Calcular promedio del grado
    const promedioGrado = Math.round(
      reportePorEstudiante.reduce((sum, r) => sum + r.promedio, 0) / reportePorEstudiante.length
    );

    res.status(200).json({
      grado: parseInt(grado),
      totalEstudiantes: estudiantes.length,
      promedioGrado,
      estudiantes: reportePorEstudiante
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener reporte', error: error.message });
  }
};

// RF-16: Reporte de progreso (para gráficas)
const getProgressChart = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    // Verificar que existe el estudiante
    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    // Obtener últimas 10 evaluaciones
    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('evaluacion_id', 'nombre')
      .sort({ fecha: -1 })
      .limit(10);

    // Invertir para mostrar en orden cronológico
    const datos = resultados.reverse().map(r => ({
      evaluacionNombre: r.evaluacion_id.nombre,
      puntuacion: r.puntuacion,
      fecha: r.fecha
    }));

    res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre
      },
      datos
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener progreso', error: error.message });
  }
};

// RF-41: Historial de evaluaciones
const getHistorialEvaluaciones = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    // Verificar estudiante
    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    // Obtener todas las evaluaciones con detalles
    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('evaluacion_id', 'nombre fecha_creacion')
      .sort({ fecha: -1 });

    res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado
      },
      historial: resultados.map(r => ({
        evaluacionId: r.evaluacion_id._id,
        evaluacionNombre: r.evaluacion_id.nombre,
        puntuacion: r.puntuacion,
        intento: r.intentos,
        fecha: r.fecha,
        aprobado: r.puntuacion >= 70
      }))
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener historial', error: error.message });
  }
};

// RF-44: Reiniciar puntuaciones (admin)
const reiniciarPuntuaciones = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;
    const { tipoReinicio } = req.body; // 'todas', 'ultima', 'reprobadas'

    if (!['todas', 'ultima', 'reprobadas'].includes(tipoReinicio)) {
      return res.status(400).json({ mensaje: 'tipoReinicio debe ser: todas, ultima o reprobadas' });
    }

    let query = { estudiante_id: estudianteId };

    if (tipoReinicio === 'ultima') {
      const ultimaEval = await Resultado.findOne({ estudiante_id: estudianteId }).sort({ fecha: -1 });
      if (ultimaEval) {
        query = { _id: ultimaEval._id };
      }
    } else if (tipoReinicio === 'reprobadas') {
      query = { estudiante_id: estudianteId, puntuacion: { $lt: 70 } };
    }

    const resultado = await Resultado.deleteMany(query);

    res.status(200).json({
      mensaje: `Se eliminaron ${resultado.deletedCount} evaluaciones`,
      tipoReinicio,
      eliminadas: resultado.deletedCount
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al reiniciar puntuaciones', error: error.message });
  }
};

module.exports = {
  getIndividualReport,
  getGradeReport,
  getProgressChart,
  getHistorialEvaluaciones,
  reiniciarPuntuaciones
};
