const express = require('express');
const router = express.Router();
const { login, registrarDocente } = require('../controllers/authController');

router.post('/login', login);
router.post('/registrar', registrarDocente);

module.exports = router;