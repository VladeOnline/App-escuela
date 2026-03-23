const express = require('express');
const router = express.Router();
const { login, registrarDocente, registrarEstudiante } = require('../controllers/authController');

router.post('/login', login);
router.post('/registrar', registrarDocente);
router.post('/registrar-estudiante', registrarEstudiante);

module.exports = router;