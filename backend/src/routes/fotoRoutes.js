const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const {
  uploadFotoDocente,
  uploadFotoEstudiante,
  getFotoDocente,
  getFotoEstudiante
} = require('../controllers/fotoController');

// Configurar multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    cb(null, `foto-${timestamp}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const tiposPermitidos = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (tiposPermitidos.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes (jpeg, png, gif, webp)'));
    }
  }
});

// Rutas para docentes
router.post('/docente/upload', upload.single('foto'), uploadFotoDocente);
router.get('/docente/:usuarioId', getFotoDocente);

// Rutas para estudiantes
router.post('/estudiante/upload', upload.single('foto'), uploadFotoEstudiante);
router.get('/estudiante/:estudianteId', getFotoEstudiante);

module.exports = router;
