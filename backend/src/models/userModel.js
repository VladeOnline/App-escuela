const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  username: { type: String, required: true, unique: true },
  password_hash: { type: String, required: true },
  rol: { type: String, enum: ['docente', 'estudiante'], required: true },
  foto_perfil_url: { type: String, default: null },
  activo: { type: Boolean, default: true },
  creado_en: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Usuario', usuarioSchema);
