const mongoose = require('mongoose');

const estudianteSchema = new mongoose.Schema({
  usuario_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario' },
  nombre: { type: String, required: true },
  edad: { type: Number, required: true },
  grado: { type: Number, required: true, min: 1, max: 6 },
  activo: { type: Boolean, default: true },
  creado_en: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Estudiante', estudianteSchema);