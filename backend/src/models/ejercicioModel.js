const mongoose = require('mongoose');

// Ejercicio: unifica lo que antes estaba en ejercicioModel, evaluacionModel y materiaModel
// Cada ejercicio pertenece directamente a un contenido (tema)
// y trae consigo todo lo necesario para ser ejecutado por el estudiante
const ejercicioSchema = new mongoose.Schema({

  // A qué contenido (tema) pertenece este ejercicio
  // Ejemplo: ejercicio de selección múltiple dentro de "Comprensión de textos"
  contenido_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Contenido',
    required: true
  },

  // Título corto del ejercicio, ej: "¿De qué trata el cuento?"
  titulo: { type: String, required: true },

  // Instrucciones que ve el estudiante antes de responder
  instrucciones: { type: String, required: true },

  // Tipo de ejercicio — define cómo se estructura el campo 'content'
  tipo: {
    type: String,
    enum: ['seleccion_multiple', 'verdadero_falso', 'completar_espacio', 'ordenamiento'],
    required: true
  },

  // Nivel de dificultad — también define cuántos puntos vale el ejercicio
  // basico = 10 pts, intermedio = 20 pts, avanzado = 30 pts
  dificultad: {
    type: String,
    enum: ['basico', 'intermedio', 'avanzado'],
    required: true
  },

  // Materia a la que corresponde el ejercicio
  // Antes era una colección separada (materiaModel), ahora es un campo directo
  materia: {
    type: String,
    enum: ['español', 'matematicas', 'ciencias', 'estudios_sociales'],
    required: true
  },

  // Puntos que otorga el ejercicio al completarlo correctamente
  // Se calcula automáticamente en el backend según la dificultad
  // basico=10, intermedio=20, avanzado=30
  puntos: { type: Number, required: true },

  // Tiempo límite en minutos para completar el ejercicio
  // Absorbido de evaluacionModel
  tiempo_limite: { type: Number, default: 5 },

  // Cantidad máxima de intentos permitidos
  // Absorbido de evaluacionModel
  intentos_max: { type: Number, default: 3 },

  // Contenido específico del ejercicio según su tipo (campo flexible JSON)
  //
  // seleccion_multiple:
  //   { passage?, question, options: [], correctIndex, explanation? }
  //
  // verdadero_falso:
  //   { passage?, statement, correctAnswer: bool, explanation? }
  //
  // completar_espacio:
  //   { passage?, template (con [BLANK]), correctAnswer, hint? }
  //
  // ordenamiento:
  //   { words: [], correctOrder: [] }
  content: {
    type: mongoose.Schema.Types.Mixed, // Mixed permite cualquier estructura JSON
    required: true
  },

  activo: { type: Boolean, default: true },

  creado_en: { type: Date, default: Date.now }

}, { collection: 'ejercicios' });

module.exports = mongoose.model('Ejercicio', ejercicioSchema, 'ejercicios');