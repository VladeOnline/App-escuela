const mongoose = require('mongoose');

const ejercicioSchema = new mongoose.Schema({
  contenido_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Contenido', required: true },
  pregunta: { type: String, required: true },
  opciones: [{ type: String }],
  respuesta_correcta: { type: String, required: true },
  dificultad: { type: String, enum: ['facil', 'medio', 'dificil'], required: true },
  activo: { type: Boolean, default: true }
});

module.exports = mongoose.model('Ejercicio', ejercicioSchema);