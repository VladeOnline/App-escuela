const mongoose = require('mongoose');

const resultadoSchema = new mongoose.Schema({
  estudiante_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Estudiante', required: true },
  evaluacion_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Evaluacion', required: true },
  puntuacion: { type: Number, required: true, min: 0 },
  intentos: { type: Number, default: 1 },
  fecha: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Resultado', resultadoSchema, 'resultados')