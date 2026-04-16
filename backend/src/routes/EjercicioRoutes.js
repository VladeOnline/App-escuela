const express = require('express');
const router = express.Router();
const { verificarToken, soloDocente, soloAdminODocente } = require('../middleware/authMiddleware');

const {
  crearEjercicio,
  obtenerEjercicios,
  obtenerEjercicioPorId,
  editarEjercicio,
  toggleEjercicio,
  bulkToggleEjercicios,
  eliminarEjercicio,
  responderEjercicio,
  obtenerResultadosPorEjercicio
} = require('../controllers/ejercicioController');

// ─────────────────────────────────────────────
// Rutas para el DOCENTE (gestión de ejercicios)
// ─────────────────────────────────────────────

// RF-10: Crear ejercicio
// POST /api/ejercicios
router.post('/', verificarToken, soloAdminODocente, crearEjercicio);
// Obtener todos los ejercicios (filtrable por contenido_id en query)
// GET /api/ejercicios?contenido_id=xxx
router.get('/', verificarToken, obtenerEjercicios);
// Activar o desactivar varios ejercicios a la vez
// PATCH /api/ejercicios/bulk-toggle
// Body: { ids: [], activo: bool }
router.patch('/bulk-toggle', verificarToken, soloAdminODocente, bulkToggleEjercicios);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Obtener un ejercicio por ID
// GET /api/ejercicios/:id
router.get('/:id', verificarToken, obtenerEjercicioPorId);

// Editar un ejercicio
// PUT /api/ejercicios/:id
router.put('/:id', verificarToken, soloAdminODocente, editarEjercicio);

// RF-12: Activar o desactivar un ejercicio (toggle inverso del estado actual)
// PATCH /api/ejercicios/:id/toggle
router.patch('/:id/toggle', verificarToken, soloAdminODocente, toggleEjercicio);


// Eliminar un ejercicio
// DELETE /api/ejercicios/:id
router.delete('/:id', verificarToken, soloAdminODocente, eliminarEjercicio);

// ─────────────────────────────────────────────
// Rutas para el ESTUDIANTE (responder ejercicios)
// ─────────────────────────────────────────────

// RF-13 + RF-14 + RF-24: Responder un ejercicio
// POST /api/ejercicios/:id/responder
// Body: { estudiante_id, respuesta_dada }
router.post('/:id/responder', verificarToken, responderEjercicio);

// Ver resultados de un ejercicio (solo docente)
// GET /api/ejercicios/:id/resultados
router.get('/:id/resultados', verificarToken, soloAdminODocente, obtenerResultadosPorEjercicio);

module.exports = router;
