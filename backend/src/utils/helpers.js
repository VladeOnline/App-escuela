const mongoose = require('mongoose');
const Log = require('../models/logModel');

/**
 * RF-26: Registrar acciones administrativas en la BD
 * @param {String} usuarioId - ObjectId del usuario que realiza la acción
 * @param {String} accion - Descripción de la acción realizada
 * @returns {Promise} Promesa del log guardado
 */
const registrarLog = async (usuarioId, accion) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(usuarioId)) {
      console.error('usuarioId inválido para log:', usuarioId);
      return null;
    }

    const nuevoLog = new Log({
      usuario_id: usuarioId,
      accion: accion,
      fecha: new Date()
    });

    return await nuevoLog.save();
  } catch (error) {
    console.error('Error al registrar log:', error.message);
    return null;
  }
};

/**
 * Validar que un ObjectId sea válido
 * @param {String} id - ID a validar
 * @returns {Boolean}
 */
const esObjectIdValido = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

/**
 * Respuesta JSON estándar de éxito
 * @param {String} mensaje
 * @param {Object} datos
 * @returns {Object}
 */
const respuestaExitosa = (mensaje, datos = null) => {
  return {
    mensaje,
    exito: true,
    ...(datos && { datos })
  };
};

/**
 * Respuesta JSON estándar de error
 * @param {String} mensaje
 * @param {String} error
 * @returns {Object}
 */
const respuestaError = (mensaje, error = null) => {
  return {
    mensaje,
    exito: false,
    ...(error && { error })
  };
};

module.exports = {
  registrarLog,
  esObjectIdValido,
  respuestaExitosa,
  respuestaError
};
