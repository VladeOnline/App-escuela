const express = require('express');
const router = express.Router();

const {
  obtenerMaterias,
  crearMateria,
  editarMateria
} = require('../controllers/materiaController');
const { verificarToken, soloDocente } = require('../middleware/authMiddleware');

router.get('/', verificarToken, obtenerMaterias);
router.post('/', verificarToken, soloDocente, crearMateria);
router.put('/:id', verificarToken, soloDocente, editarMateria);

module.exports = router;
