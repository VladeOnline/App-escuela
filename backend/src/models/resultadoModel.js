const mongoose = require('mongoose');

const resultadoSchema = new mongoose.Schema({
  estudiante_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Estudiante', required: true },
  evaluacion_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Evaluacion', required: true },
  puntuacion: { type: Number, required: true, min: 0 },
  intentos: { type: Number, default: 1 },
  fecha: { type: Date, default: Date.now },
  tiempo_utilizado: { type: Number, default: 0 },
  preguntas_correctas: { type: Number, default: 0 },
  total_preguntas: { type: Number, default: 0 }
});

resultadoSchema.index({ estudiante_id: 1, evaluacion_id: 1 });
resultadoSchema.index({ estudiante_id: 1, fecha: -1 });

module.exports = mongoose.model('Resultado', resultadoSchema, 'resultados')