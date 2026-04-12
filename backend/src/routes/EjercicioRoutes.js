const express = require('express');
const router = express.Router();

const {
  crearEjercicio,
  cambiarEstadoEjercicio,
  obtenerEjercicios,
  responderPregunta,
  finalizarEvaluacion,
  obtenerResultadosPorEvaluacion
} = require('../controllers/ejercicioController');

// RF-10: crear ejercicio
router.post('/', crearEjercicio);

// RF-12: activar/desactivar ejercicio
router.patch('/:id/estado', cambiarEstadoEjercicio);

// Obtener ejercicios
router.get('/', obtenerEjercicios);

// RF-13 y RF-14
router.post('/responder', responderPregunta);
router.post('/finalizar', finalizarEvaluacion);

// Resultados por evaluación
router.get('/resultados/:id', obtenerResultadosPorEvaluacion);

module.exports = router;
