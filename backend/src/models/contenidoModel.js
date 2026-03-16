const mongoose = require('mongoose');

const contenidoSchema = new mongoose.Schema({
  materia_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Materia', required: true },
  titulo: { type: String, required: true },
  descripcion: { type: String },
  activo: { type: Boolean, default: true }
});

module.exports = mongoose.model('Contenido', contenidoSchema);