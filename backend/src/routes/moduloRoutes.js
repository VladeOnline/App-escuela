const express = require('express');
const router = express.Router();
const { verificarToken } = require('../middleware/authMiddleware');

const {
  obtenerModulos,
  obtenerModuloPorTipo
} = require('../controllers/moduloController');

// GET /api/modulos
// Devuelve los 3 módulos fijos (lectura, escritura, matemáticas)
// Cualquier usuario autenticado puede verlos
router.get('/', verificarToken, obtenerModulos);

// GET /api/modulos/:tipo
// Devuelve un módulo con todos sus contenidos agrupados por grado
// Ejemplo: GET /api/modulos/lectura
router.get('/:tipo', verificarToken, obtenerModuloPorTipo);

module.exports = router;