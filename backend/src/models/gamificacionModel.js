const mongoose = require('mongoose');

const gamificacionSchema = new mongoose.Schema({
  estudiante_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Estudiante', required: true },
  puntos_total: { type: Number, default: 0 },
  nivel: { type: Number, default: 1 },
  insignias: [{ type: String }],
  actualizado_en: { type: Date, default: Date.now }
});

gamificacionSchema.index({ estudiante_id: 1 });
gamificacionSchema.index({ puntos_total: -1 });

module.exports = mongoose.model('Gamificacion', gamificacionSchema);
