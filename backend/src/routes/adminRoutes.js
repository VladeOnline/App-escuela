const express = require('express');
const router = express.Router();
const { deleteAllStudents, resetSystem } = require('../controllers/adminController');

// Rutas de administración

// Borrar todos los estudiantes
router.post('/delete-all-students', deleteAllStudents);

// Reiniciar sistema (borrar todo menos docente)
router.post('/reset-system', resetSystem);

module.exports = router;
