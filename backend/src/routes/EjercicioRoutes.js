const express = require('express');
const router = express.Router();
const { verificarToken, soloAdminODocente } = require('../middleware/authMiddleware');

const {
  crearEjercicio,
  cambiarDificultadEjercicio,
  cambiarEstadoEjercicio,
  obtenerEjercicios,
  responderPregunta,
  finalizarEvaluacion,
  obtenerResultadosPorEvaluacion
} = require('../controllers/ejercicioController');

// RF-10: crear ejercicio (solo docentes/admins)
router.post('/', verificarToken, soloAdminODocente, crearEjercicio);

// RF-12: activar/desactivar ejercicio (solo docentes/admins)
router.patch('/:id/estado', verificarToken, soloAdminODocente, cambiarEstadoEjercicio);

// RF-11: cambiar dificultad de ejercicio (solo docentes/admins)
router.patch('/:id/dificultad', verificarToken, soloAdminODocente, cambiarDificultadEjercicio);

// Obtener ejercicios
router.get('/', verificarToken, obtenerEjercicios);

// RF-13 y RF-14: Responder pregunta y finalizar evaluación (estudiantes)
router.post('/responder', verificarToken, responderPregunta);
router.post('/finalizar', verificarToken, finalizarEvaluacion);

// Resultados por evaluación (solo docentes/admins)
router.get('/resultados/:id', verificarToken, soloAdminODocente, obtenerResultadosPorEvaluacion);

module.exports = router;