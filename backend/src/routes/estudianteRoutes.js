const express = require('express');
const router = express.Router();
const {
  obtenerEstudiantes,
  crearEstudiante,
  editarEstudiante,
  eliminarEstudiante
} = require('../controllers/estudianteController');

router.get('/', obtenerEstudiantes);
router.post('/', crearEstudiante);
router.put('/:id', editarEstudiante);
router.delete('/:id', eliminarEstudiante);

module.exports = router;