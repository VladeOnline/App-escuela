const Estudiante = require('../models/studentModel');
const Resultado = require('../models/resultadoModel');
const Gamificacion = require('../models/gamificacionModel');

const materiaLabel = (raw) => {
  const normalized = String(raw || '').toLowerCase().trim();
  switch (normalized) {
    case 'espanol':
    case 'espa\u00f1ol':
      return 'Espa\u00f1ol';
    case 'matematicas':
    case 'matem\u00e1ticas':
      return 'Matem\u00e1ticas';
    case 'ciencias':
      return 'Ciencias';
    case 'estudios_sociales':
      return 'Est. Sociales';
    case 'civica':
    case 'c\u00edvica':
      return 'C\u00edvica';
    default:
      return 'General';
  }
};

// RF-17: Reporte individual de un estudiante
const getIndividualReport = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    const estudiante = await Estudiante.findById(estudianteId).populate(
      'usuario_id',
      'nombre foto_perfil_url',
    );
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate({
        path: 'ejercicio_id',
        select: 'titulo materia contenido_id',
        populate: { path: 'contenido_id', select: 'tipo_modulo' },
      })
      .sort({ fecha: -1 });

    const resultadosPayload = resultados.map((r) => {
      const ejercicio = r.ejercicio_id;
      const puntuacion = Number(r.puntuacion || 0);
      return {
        id: r._id,
        estudianteId: r.estudiante_id,
        evaluacionId: ejercicio?._id?.toString() ?? '',
        evaluacionTitulo: ejercicio?.titulo ?? 'Sin titulo',
        materia: materiaLabel(ejercicio?.materia),
        puntuacion,
        fecha: r.fecha,
        aprobado: puntuacion >= 70,
        intentos: Number(r.intentos || 1),
        tipoModulo: ejercicio?.contenido_id?.tipo_modulo || null,
      };
    });

    const totalEvaluaciones = resultadosPayload.length;
    const sumaPuntuaciones = resultadosPayload.reduce((sum, r) => sum + r.puntuacion, 0);
    const promedio = totalEvaluaciones > 0
      ? Math.round(sumaPuntuaciones / totalEvaluaciones)
      : 0;
    const aprobadas = resultadosPayload.filter((r) => r.aprobado).length;

    // Rendimiento por materia separando Lectura/Escritura por tipo de modulo.
    const bucket = new Map();
    for (const item of resultadosPayload) {
      if (!bucket.has(item.materia)) {
        bucket.set(item.materia, {
          sum: 0,
          count: 0,
          lecturaSum: 0,
          lecturaCount: 0,
          escrituraSum: 0,
          escrituraCount: 0,
        });
      }
      const b = bucket.get(item.materia);
      b.sum += item.puntuacion;
      b.count += 1;

      if (item.tipoModulo === 'lectura') {
        b.lecturaSum += item.puntuacion;
        b.lecturaCount += 1;
      } else if (item.tipoModulo === 'escritura') {
        b.escrituraSum += item.puntuacion;
        b.escrituraCount += 1;
      }
    }

    const rendimientoPorMateria = Array.from(bucket.entries()).map(([nombre, b]) => {
      const promedioMateria = b.count > 0 ? Math.round(b.sum / b.count) : 0;
      const lectura = b.lecturaCount > 0
        ? Math.round(b.lecturaSum / b.lecturaCount)
        : promedioMateria;
      const escritura = b.escrituraCount > 0
        ? Math.round(b.escrituraSum / b.escrituraCount)
        : promedioMateria;
      return { nombre, lectura, escritura };
    });

    // Progreso semanal de las ultimas 6 semanas (si no hay datos en una semana, arrastra ultimo valor).
    const now = new Date();
    const weekStart = new Date(now);
    const day = (weekStart.getDay() + 6) % 7; // lunes=0
    weekStart.setDate(weekStart.getDate() - day);
    weekStart.setHours(0, 0, 0, 0);

    const sixWeeks = [];
    for (let i = 5; i >= 0; i -= 1) {
      const start = new Date(weekStart);
      start.setDate(start.getDate() - i * 7);
      const end = new Date(start);
      end.setDate(end.getDate() + 7);

      const weekScores = resultadosPayload
        .filter((r) => {
          const f = new Date(r.fecha);
          return f >= start && f < end;
        })
        .map((r) => r.puntuacion);

      const value = weekScores.length > 0
        ? Math.round(weekScores.reduce((a, v) => a + v, 0) / weekScores.length)
        : null;
      sixWeeks.push({ week: `Sem ${6 - i}`, value });
    }

    let lastKnown = 0;
    const progresoSemanal = sixWeeks.map((w) => {
      if (w.value != null) lastKnown = w.value;
      return { week: w.week, value: w.value ?? lastKnown };
    });

    const gamificacion = await Gamificacion.findOne({ estudiante_id: estudianteId });

    // Ranking del estudiante en su grado.
    const companeros = await Estudiante.find({ grado: estudiante.grado, activo: true }, '_id');
    const idsMismoGrado = companeros.map((e) => e._id);
    const rankingRows = await Gamificacion.find(
      { estudiante_id: { $in: idsMismoGrado } },
      'estudiante_id puntos_total',
    );
    rankingRows.sort((a, b) => (b.puntos_total || 0) - (a.puntos_total || 0));
    let ranking = rankingRows.findIndex(
      (r) => String(r.estudiante_id) === String(estudianteId),
    );
    ranking = ranking >= 0 ? ranking + 1 : 0;

    return res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado,
        foto_url: estudiante?.usuario_id?.foto_perfil_url ?? null,
      },
      resumen: {
        totalEvaluaciones,
        promedio,
        aprobadas,
      },
      resultados: resultadosPayload.map((r) => ({
        id: r.id,
        estudianteId: r.estudianteId,
        evaluacionId: r.evaluacionId,
        evaluacionTitulo: r.evaluacionTitulo,
        materia: r.materia,
        puntuacion: r.puntuacion,
        fecha: r.fecha,
        aprobado: r.aprobado,
        intentos: r.intentos,
      })),
      rendimientoPorMateria,
      progresoSemanal,
      gamificacion: {
        xpPoints: Number(gamificacion?.puntos_total || 0),
        ranking,
        levelName: gamificacion?.nivel ? `Nivel ${gamificacion.nivel}` : 'Nivel 1',
        insignias: Array.isArray(gamificacion?.insignias) ? gamificacion.insignias : [],
      },
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener reporte', error: error.message });
  }
};

// RF-18: Reporte por grado (comparativa)
const getGradeReport = async (req, res) => {
  try {
    const { grado } = req.params;
    const estudiantes = await Estudiante.find({ grado: parseInt(grado, 10) });

    if (estudiantes.length === 0) {
      return res.status(404).json({ mensaje: 'No hay estudiantes para ese grado' });
    }

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
          totalEvaluaciones: resultados.length,
        };
      }),
    );

    const promedioGrado = Math.round(
      reportePorEstudiante.reduce((sum, r) => sum + r.promedio, 0) / reportePorEstudiante.length,
    );

    return res.status(200).json({
      grado: parseInt(grado, 10),
      totalEstudiantes: estudiantes.length,
      promedioGrado,
      estudiantes: reportePorEstudiante,
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener reporte', error: error.message });
  }
};

// RF-16: Reporte de progreso (para graficas)
const getProgressChart = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('ejercicio_id', 'titulo')
      .sort({ fecha: -1 })
      .limit(10);

    const datos = resultados.reverse().map((r) => ({
      evaluacionNombre: r.ejercicio_id?.titulo ?? 'Sin titulo',
      puntuacion: r.puntuacion,
      fecha: r.fecha,
    }));

    return res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
      },
      datos,
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener progreso', error: error.message });
  }
};

// RF-41: Historial de evaluaciones
const getHistorialEvaluaciones = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;

    const estudiante = await Estudiante.findById(estudianteId);
    if (!estudiante) {
      return res.status(404).json({ mensaje: 'Estudiante no encontrado' });
    }

    const resultados = await Resultado.find({ estudiante_id: estudianteId })
      .populate('ejercicio_id', 'titulo creado_en')
      .sort({ fecha: -1 });

    return res.status(200).json({
      estudiante: {
        id: estudiante._id,
        nombre: estudiante.nombre,
        grado: estudiante.grado,
      },
      historial: resultados.map((r) => ({
        evaluacionId: r.ejercicio_id?._id ?? null,
        evaluacionNombre: r.ejercicio_id?.titulo ?? 'Sin titulo',
        puntuacion: r.puntuacion,
        intento: r.intentos,
        fecha: r.fecha,
        aprobado: r.puntuacion >= 70,
      })),
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener historial', error: error.message });
  }
};

// RF-44: Reiniciar puntuaciones
const reiniciarPuntuaciones = async (req, res) => {
  try {
    const { id: estudianteId } = req.params;
    const { tipoReinicio } = req.body;

    if (!['todas', 'ultima', 'reprobadas'].includes(tipoReinicio)) {
      return res.status(400).json({ mensaje: 'tipoReinicio debe ser: todas, ultima o reprobadas' });
    }

    let query = { estudiante_id: estudianteId };

    if (tipoReinicio === 'ultima') {
      const ultimaEval = await Resultado.findOne({ estudiante_id: estudianteId }).sort({ fecha: -1 });
      if (ultimaEval) query = { _id: ultimaEval._id };
    } else if (tipoReinicio === 'reprobadas') {
      query = { estudiante_id: estudianteId, puntuacion: { $lt: 70 } };
    }

    const resultado = await Resultado.deleteMany(query);

    return res.status(200).json({
      mensaje: `Se eliminaron ${resultado.deletedCount} evaluaciones`,
      tipoReinicio,
      eliminadas: resultado.deletedCount,
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al reiniciar puntuaciones', error: error.message });
  }
};

module.exports = {
  getIndividualReport,
  getGradeReport,
  getProgressChart,
  getHistorialEvaluaciones,
  reiniciarPuntuaciones,
};
