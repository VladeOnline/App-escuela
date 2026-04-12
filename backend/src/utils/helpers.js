const Log = require('../models/logModel');

/**
 * Registra una acción de un usuario en la base de datos.
 * Usado por los controllers para auditoría (RF-26).
 *
 * @param {string} usuarioId - ID del usuario que realizó la acción
 * @param {string} accion    - Descripción de la acción realizada
 */
const registrarLog = async (usuarioId, accion) => {
  try {
    await Log.create({ usuario_id: usuarioId, accion });
  } catch (error) {
    // No interrumpimos el flujo principal si el log falla
    console.error('[registrarLog] Error al guardar log:', error.message);
  }
};

module.exports = { registrarLog };