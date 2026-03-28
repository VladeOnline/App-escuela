const mongoose = require('mongoose');


const respuestaSchema = new mongoose.Schema({
  estudiante_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Estudiante', required: true },
  evaluacion_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Evaluacion', required: true },
  ejercicio_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Ejercicio', required: true },
  respuesta_dada: { type: String, required: true },
  es_correcta: { type: Boolean, required: true },
  puntos_obtenidos: { type: Number, required: true, default: 0 },
  fecha: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Respuesta', respuestaSchema, 'respuestas');