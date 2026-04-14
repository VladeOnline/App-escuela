const mongoose = require('mongoose');

// RankingSnapshot guarda los puntos acumulados de un estudiante
// al inicio de cada periodo (semana / mes).
// Sirve para calcular puntos ganados DENTRO del periodo sin tocar
// el campo puntos_total de Gamificacion, que es el acumulado historico.
//
// Logica:
//   puntos_en_periodo = puntos_total_actual - puntos_al_inicio_del_periodo
//
// El snapshot se crea automaticamente la primera vez que se consulta
// el ranking si aun no existe para ese periodo.
const rankingSnapshotSchema = new mongoose.Schema(
  {
    estudiante_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Estudiante',
      required: true,
    },
    // 'semana' | 'mes'
    periodo: {
      type: String,
      enum: ['semana', 'mes'],
      required: true,
    },
    // Primer dia del periodo (lunes de la semana o dia 1 del mes)
    // Guardado como string 'YYYY-MM-DD' para facilitar agrupacion
    periodo_inicio: {
      type: String,
      required: true,
    },
    // Puntos que tenia el estudiante al inicio del periodo
    puntos_inicio: {
      type: Number,
      default: 0,
    },
    creado_en: {
      type: Date,
      default: Date.now,
    },
  },
  { collection: 'ranking_snapshots' },
);

// Indice compuesto: un snapshot por estudiante por periodo por inicio
rankingSnapshotSchema.index(
  { estudiante_id: 1, periodo: 1, periodo_inicio: 1 },
  { unique: true },
);

module.exports = mongoose.model('RankingSnapshot', rankingSnapshotSchema);
