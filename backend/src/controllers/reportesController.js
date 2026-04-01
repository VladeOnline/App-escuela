const mongoose = require('mongoose');
const Resultado = require('../models/resultadoModel');
const Estudiante = require('../models/studentModel');

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

module.exports = {
  obtenerReporteIndividual,
  obtenerReportePorGrado,
  obtenerProgresoGraficas
};