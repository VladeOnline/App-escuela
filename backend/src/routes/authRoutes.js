const express = require('express');
const router = express.Router();
const {
  login,
  registrarDocente,
  registrarEstudiante,
  actualizarFotoPerfil,
  deleteAccount,
} = require('../controllers/authController');
const { verificarToken } = require('../middleware/authMiddleware');

router.post('/login', login);
router.post('/registrar', registrarDocente);
router.post('/registrar-estudiante', registrarEstudiante);
router.patch('/me/foto-perfil', verificarToken, actualizarFotoPerfil);
router.delete('/me', verificarToken, deleteAccount);

module.exports = router;
