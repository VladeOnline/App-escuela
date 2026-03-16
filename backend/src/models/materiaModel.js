const mongoose = require('mongoose');

const materiaSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  grado: { type: Number, required: true, min: 1, max: 6 },
  activa: { type: Boolean, default: true }
});

module.exports = mongoose.model('Materia', materiaSchema);