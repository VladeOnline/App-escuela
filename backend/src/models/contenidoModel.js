const mongoose = require('mongoose');

// Contenido: representa un tema dentro de un módulo, separado por grado
// Ejemplos: "Comprensión de textos" (grado 2, lectura)
//           "Abecedario" (grado 1, escritura)
//           "Sumas básicas" (grado 2, matemáticas)
const contenidoSchema = new mongoose.Schema({

  // Tipo de módulo al que pertenece este contenido
  // Es un string directo porque los módulos son fijos y hardcodeados
  // No necesitamos una referencia a MongoDB para esto
  tipo_modulo: {
    type: String,
    enum: ['lectura', 'escritura', 'matematicas'],
    required: true
  },

  // Nombre del tema, ej: "Comprensión de textos"
  titulo: { type: String, required: true },

  // Descripción corta que aparece en la tarjeta del módulo
  descripcion: { type: String, default: '' },

  // Grado al que está destinado este contenido (1 a 6)
  grado: { type: Number, required: true, min: 1, max: 6 },

  activo: { type: Boolean, default: true },

  creado_en: { type: Date, default: Date.now }

}, { collection: 'contenidos' });

module.exports = mongoose.model('Contenido', contenidoSchema, 'contenidos');