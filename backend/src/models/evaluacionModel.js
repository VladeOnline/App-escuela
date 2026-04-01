const mongoose = require('mongoose');

const evaluacionSchema = new mongoose.Schema({
  materia_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Materia', required: true },
  titulo: { type: String, required: true },
  tiempo_limite: { type: Number, required: true },
  intentos_max: { type: Number, required: true },
  instrucciones: { type: String, default: '' },
  activa: { type: Boolean, default: true },
  creado_en: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Evaluacion', evaluacionSchema, 'evaluaciones');