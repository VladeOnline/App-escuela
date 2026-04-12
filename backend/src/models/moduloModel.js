const mongoose = require('mongoose');
 
// Módulo: representa uno de los 3 tipos fijos del sistema
// Lectura, Escritura o Matemáticas
// Los contenidos (temas por grado) pertenecen a un módulo
const moduloSchema = new mongoose.Schema({
 
  // El tipo define cuál de los 3 módulos es
  tipo: {
    type: String,
    enum: ['lectura', 'escritura', 'matematicas'],
    required: true,
    unique: true // Solo puede existir uno de cada tipo
  },
 
  activo: { type: Boolean, default: true }
 
}, { collection: 'modulos' });
 
module.exports = mongoose.model('Modulo', moduloSchema, 'modulos');
 