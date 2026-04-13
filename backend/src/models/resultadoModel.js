const mongoose = require('mongoose');

// Resultado: guarda la nota final de un estudiante en un ejercicio
// Ahora apunta directamente a ejercicio_id en vez de evaluacion_id
// ya que los ejercicios absorbieron la funcionalidad de las evaluaciones
const resultadoSchema = new mongoose.Schema({

  // Quién realizó el ejercicio
  estudiante_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Estudiante',
    required: true
  },

  // Qué ejercicio realizó
  // Antes era evaluacion_id — ahora apunta directo al ejercicio
  ejercicio_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ejercicio',
    required: true
  },

  // Puntuación obtenida: 0 si falló, o los puntos del ejercicio si acertó
  puntuacion: { type: Number, required: true, min: 0 },

  // En qué intento lo logró (1, 2, 3...)
  intentos: { type: Number, default: 1 },

  // Si respondió correctamente o no
  es_correcto: { type: Boolean, required: true },

  // Fecha y hora exacta en que terminó
  fecha: { type: Date, default: Date.now }

}, { collection: 'resultados' });

// Índices para búsquedas frecuentes del docente
resultadoSchema.index({ estudiante_id: 1, ejercicio_id: 1 });
resultadoSchema.index({ estudiante_id: 1, fecha: -1 });

module.exports = mongoose.model('Resultado', resultadoSchema, 'resultados');