const express = require('express');
const router = express.Router();
const { verificarToken, soloAdminODocente } = require('../middleware/authMiddleware');

const {
  crearContenido,
  obtenerContenidos,
  obtenerContenidoPorId,
  editarContenido,
  eliminarContenido,
  toggleContenido
} = require('../controllers/contenidoController');

// Crear contenido (solo docentes)
// POST /api/contenidos
// Body: { tipo_modulo, titulo, descripcion?, grado }
router.post('/', verificarToken, soloAdminODocente, crearContenido);

// Obtener contenidos (filtrable por tipo_modulo y/o grado)
// GET /api/contenidos?tipo_modulo=lectura&grado=2
router.get('/', verificarToken, obtenerContenidos);

// Obtener un contenido por ID con su conteo de ejercicios
// GET /api/contenidos/:id
router.get('/:id', verificarToken, obtenerContenidoPorId);

// Editar un contenido
// PUT /api/contenidos/:id
router.put('/:id', verificarToken, soloAdminODocente, editarContenido);

// Activar o desactivar un contenido
// PATCH /api/contenidos/:id/toggle
router.patch('/:id/toggle', verificarToken, soloAdminODocente, toggleContenido);

// Eliminar un contenido (solo si no tiene ejercicios)
// DELETE /api/contenidos/:id
router.delete('/:id', verificarToken, soloAdminODocente, eliminarContenido);

module.exports = router;