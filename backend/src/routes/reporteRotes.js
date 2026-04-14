const express = require('express');
const router = express.Router();
const {
  getIndividualReport,
  getGradeReport,
  getProgressChart,
  getHistorialEvaluaciones,
  reiniciarPuntuaciones
} = require('../controllers/reporteController');

// RF-17: Reporte individual de un estudiante
router.get('/individual/:id', getIndividualReport);

// RF-18: Reporte por grado
router.get('/grado/:grado', getGradeReport);

// RF-16: Reporte de progreso
router.get('/progreso/:id', getProgressChart);

// RF-41: Historial de evaluaciones
router.get('/historial/:id', getHistorialEvaluaciones);

// RF-44: Reiniciar puntuaciones
router.post('/admin/reiniciar/:id', reiniciarPuntuaciones);

module.exports = router;
