const express = require('express');
const router = express.Router();

const {
  obtenerContenidos,
  crearContenido,
  editarContenido
} = require('../controllers/contenidoController');
const { verificarToken, soloDocente } = require('../middleware/authMiddleware');

router.get('/', verificarToken, obtenerContenidos);
router.post('/', verificarToken, soloDocente, crearContenido);
router.put('/:id', verificarToken, soloDocente, editarContenido);

module.exports = router;
