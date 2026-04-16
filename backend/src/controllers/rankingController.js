const Gamificacion = require('../models/gamificacionModel');
const Estudiante = require('../models/studentModel');
const Usuario = require('../models/userModel');
const RankingSnapshot = require('../models/rankingModel');

// Helpers de fecha
const getLunesActual = () => {
  const hoy = new Date();
  const diaSemana = hoy.getDay(); // 0=dom, 1=lun, ..., 6=sab
  const diffLunes = diaSemana === 0 ? -6 : 1 - diaSemana;
  const lunes = new Date(hoy);
  lunes.setDate(hoy.getDate() + diffLunes);
  return lunes.toISOString().slice(0, 10); // 'YYYY-MM-DD'
};

const getPrimerDiaMes = () => {
  const hoy = new Date();
  return `${hoy.getFullYear()}-${String(hoy.getMonth() + 1).padStart(2, '0')}-01`;
};

const asegurarSnapshots = async (estudianteIds, periodo, periodoInicio) => {
  const existentes = await RankingSnapshot.find({
    estudiante_id: { $in: estudianteIds },
    periodo,
    periodo_inicio: periodoInicio,
  }).select('estudiante_id');

  const idsConSnapshot = new Set(existentes.map((s) => s.estudiante_id.toString()));
  const idsSinSnapshot = estudianteIds.filter((id) => !idsConSnapshot.has(id.toString()));

  if (idsSinSnapshot.length === 0) return;

  const gamificaciones = await Gamificacion.find({
    estudiante_id: { $in: idsSinSnapshot },
  }).select('estudiante_id puntos_total');

  const puntosMap = {};
  for (const g of gamificaciones) {
    puntosMap[g.estudiante_id.toString()] = g.puntos_total;
  }

  const nuevosSnapshots = idsSinSnapshot.map((id) => ({
    estudiante_id: id,
    periodo,
    periodo_inicio: periodoInicio,
    puntos_inicio: puntosMap[id.toString()] ?? 0,
  }));

  await RankingSnapshot.insertMany(nuevosSnapshots, { ordered: false }).catch(() => {
    // ordered:false + ignorar errores de duplicado por race condition
  });
};

// GET /api/ranking?grado=2&periodo=semana&top=10
const obtenerRanking = async (req, res) => {
  try {
    const { grado, periodo = 'semana', top = 10 } = req.query;

    if (!grado) {
      return res.status(400).json({ mensaje: 'El parametro grado es obligatorio' });
    }

    const periodosValidos = ['semana', 'mes', 'total'];
    if (!periodosValidos.includes(periodo)) {
      return res.status(400).json({ mensaje: 'periodo debe ser: semana, mes o total' });
    }

    const topN = Math.min(Math.max(parseInt(top, 10) || 10, 1), 50);

    const estudiantes = await Estudiante.find({ grado: Number(grado), activo: true })
      .select('_id nombre usuario_id')
      .populate('usuario_id', 'foto_perfil_url');

    if (estudiantes.length === 0) {
      return res.status(200).json({ ranking: [], periodo, grado: Number(grado) });
    }

    const estudianteIds = estudiantes.map((e) => e._id);

    const gamificaciones = await Gamificacion.find({
      estudiante_id: { $in: estudianteIds },
    }).select('estudiante_id puntos_total');

    const gamMap = {};
    for (const g of gamificaciones) {
      gamMap[g.estudiante_id.toString()] = g.puntos_total;
    }

    const puntosDelPeriodo = {}; // estudianteId -> puntos en el periodo

    if (periodo === 'total') {
      for (const id of estudianteIds) {
        puntosDelPeriodo[id.toString()] = gamMap[id.toString()] ?? 0;
      }
    } else {
      const periodoInicio = periodo === 'semana' ? getLunesActual() : getPrimerDiaMes();
      await asegurarSnapshots(estudianteIds, periodo, periodoInicio);

      const snapshots = await RankingSnapshot.find({
        estudiante_id: { $in: estudianteIds },
        periodo,
        periodo_inicio: periodoInicio,
      }).select('estudiante_id puntos_inicio');

      const snapMap = {};
      for (const s of snapshots) {
        snapMap[s.estudiante_id.toString()] = s.puntos_inicio;
      }

      for (const id of estudianteIds) {
        const idStr = id.toString();
        const puntosActuales = gamMap[idStr] ?? 0;
        const puntosInicio = snapMap[idStr] ?? 0;
        puntosDelPeriodo[idStr] = Math.max(0, puntosActuales - puntosInicio);
      }
    }

    const estudianteMap = {};
    for (const e of estudiantes) {
      estudianteMap[e._id.toString()] = e;
    }

    const resultados = estudianteIds
      .map((id) => {
        const idStr = id.toString();
        const est = estudianteMap[idStr];
        const puntos = puntosDelPeriodo[idStr] ?? 0;
        return {
          estudiante_id: idStr,
          nombre: est?.nombre ?? 'Desconocido',
          foto_url: est?.usuario_id?.foto_perfil_url ?? null,
          puntos,
        };
      })
      .sort((a, b) => b.puntos - a.puntos)
      .slice(0, topN)
      .map((item, index) => ({ ...item, posicion: index + 1 }));

    return res.status(200).json({
      ranking: resultados,
      periodo,
      grado: Number(grado),
      total_estudiantes: estudiantes.length,
    });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener el ranking', error: error.message });
  }
};

// GET /api/ranking/posicion?estudiante_id=xxx&grado=2
const obtenerPosicionEstudiante = async (req, res) => {
  try {
    const { estudiante_id, grado } = req.query;

    if (!estudiante_id || !grado) {
      return res.status(400).json({ mensaje: 'Se requieren: estudiante_id y grado' });
    }

    const resultados = {};

    for (const periodo of ['semana', 'mes', 'total']) {
      const fakeReq = { query: { grado, periodo, top: 50 } };
      let rankingData = null;

      await new Promise((resolve) => {
        const fakeRes = {
          status: () => fakeRes,
          json: (data) => {
            rankingData = data;
            resolve();
          },
        };
        obtenerRanking(fakeReq, fakeRes);
      });

      const posicion = rankingData?.ranking?.findIndex((r) => r.estudiante_id === estudiante_id);
      const entry = rankingData?.ranking?.find((r) => r.estudiante_id === estudiante_id);

      resultados[periodo] = {
        posicion: posicion !== undefined && posicion >= 0 ? posicion + 1 : null,
        puntos: entry?.puntos ?? 0,
        total_estudiantes: rankingData?.total_estudiantes ?? 0,
      };
    }

    return res.status(200).json({ posiciones: resultados, estudiante_id, grado: Number(grado) });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error al obtener posición', error: error.message });
  }
};

module.exports = { obtenerRanking, obtenerPosicionEstudiante };
