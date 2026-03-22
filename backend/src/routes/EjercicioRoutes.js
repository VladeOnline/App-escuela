const express = require('express');
const router = express.Router();

const {
  crearEjercicio,
  responderPregunta,
  finalizarEvaluacion,
  obtenerResultadosPorEvaluacion
} = require('../controllers/ejercicioController');

// POST /api/ejercicios
// El docente crea un ejercicio y lo vincula a una evaluación (RF-10)
router.post('/', crearEjercicio);

// POST /api/ejercicios/responder
// El estudiante responde UNA pregunta → el sistema responde si fue correcta o no
// Flutter llama esto una vez por cada pregunta durante la evaluación estilo Kahoot
router.post('/responder', responderPregunta);

// POST /api/ejercicios/finalizar
// Flutter llama esto UNA SOLA VEZ al terminar todas las preguntas
// Calcula la nota final (0-100) y la guarda en la BD (RF-13 + RF-14)
router.post('/finalizar', finalizarEvaluacion);

// GET /api/ejercicios/resultados/:id
// El docente consulta los resultados de una evaluación específica
router.get('/resultados/:id', obtenerResultadosPorEvaluacion);

module.exports = router;