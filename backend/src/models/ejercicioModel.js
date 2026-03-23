const mongoose = require('mongoose');
 
const ejercicioSchema = new mongoose.Schema({
  contenido_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Contenido', required: true },
 
  // CAMPO NUEVO: vincula el ejercicio a una evaluación específica
  // Ejemplo: los 4 ejercicios de "Evaluación de Fracciones" tendrán el mismo evaluacion_id
  evaluacion_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Evaluacion', required: true },
 
  pregunta: { type: String, required: true },
  opciones: [{ type: String }],             // Ej: ["3", "4", "5", "6"]
  respuesta_correcta: { type: String, required: true },
  dificultad: { type: String, enum: ['facil', 'medio', 'dificil'], required: true },
  activo: { type: Boolean, default: true }
});
 
module.exports = mongoose.model('Ejercicio', ejercicioSchema, 'ejercicios');
