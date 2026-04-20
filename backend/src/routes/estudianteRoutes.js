const express = require('express');
const router = express.Router();
const {
  obtenerEstudiantes,
  crearEstudiante,
  editarEstudiante,
  eliminarEstudiante,
  resetAll
} = require('../controllers/estudianteController');
const { verificarToken, soloDocente } = require('../middleware/authMiddleware');

router.get('/', verificarToken, obtenerEstudiantes);
router.post('/', verificarToken, soloDocente, crearEstudiante);
router.put('/:id', verificarToken, soloDocente, editarEstudiante);
router.delete('/reset-all', verificarToken, soloDocente, resetAll);
router.delete('/:id', verificarToken, soloDocente, eliminarEstudiante);

module.exports = router;