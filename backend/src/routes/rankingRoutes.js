const express = require('express');
const router = express.Router();
const { verificarToken } = require('../middleware/authMiddleware');
const { obtenerRanking, obtenerPosicionEstudiante } = require('../controllers/rankingController');

// GET /api/ranking?grado=2&periodo=semana&top=10
// Cualquier usuario autenticado puede ver el ranking de su grado
router.get('/', verificarToken, obtenerRanking);

// GET /api/ranking/posicion?estudiante_id=xxx&grado=2
// Devuelve la posición del estudiante en los 3 períodos
router.get('/posicion', verificarToken, obtenerPosicionEstudiante);

module.exports = router;
