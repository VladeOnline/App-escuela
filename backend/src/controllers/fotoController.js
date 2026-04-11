const Usuario = require('../models/userModel');
const Estudiante = require('../models/studentModel');
const fs = require('fs');
const path = require('path');

// Crear directorio de uploads si no existe
const uploadsDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Subir foto de docente
const uploadFotoDocente = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ mensaje: 'No se envió archivo' });
    }

    const { usuarioId } = req.body;
    if (!usuarioId) {
      return res.status(400).json({ mensaje: 'Se requiere usuarioId' });
    }

    // Eliminar foto anterior si existe
    const usuario = await Usuario.findById(usuarioId);
    if (usuario && usuario.foto_url) {
      const fotoAnterior = path.join(__dirname, '../../', usuario.foto_url);
      if (fs.existsSync(fotoAnterior)) {
        fs.unlinkSync(fotoAnterior);
      }
    }

    // Guardar nueva foto
    const fotoUrl = `/uploads/${req.file.filename}`;
    await Usuario.findByIdAndUpdate(
      usuarioId,
      { foto_url: fotoUrl },
      { new: true }
    );

    res.status(200).json({
      mensaje: 'Foto actualizada correctamente',
      foto_url: fotoUrl
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al subir foto', error: error.message });
  }
};

// Subir foto de estudiante
const uploadFotoEstudiante = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ mensaje: 'No se envió archivo' });
    }

    const { estudianteId } = req.body;
    if (!estudianteId) {
      return res.status(400).json({ mensaje: 'Se requiere estudianteId' });
    }

    // Eliminar foto anterior si existe
    const estudiante = await Estudiante.findById(estudianteId);
    if (estudiante && estudiante.foto_url) {
      const fotoAnterior = path.join(__dirname, '../../', estudiante.foto_url);
      if (fs.existsSync(fotoAnterior)) {
        fs.unlinkSync(fotoAnterior);
      }
    }

    // Guardar nueva foto
    const fotoUrl = `/uploads/${req.file.filename}`;
    await Estudiante.findByIdAndUpdate(
      estudianteId,
      { foto_url: fotoUrl },
      { new: true }
    );

    res.status(200).json({
      mensaje: 'Foto actualizada correctamente',
      foto_url: fotoUrl
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al subir foto', error: error.message });
  }
};

// Obtener foto de usuario (docente)
const getFotoDocente = async (req, res) => {
  try {
    const { usuarioId } = req.params;
    const usuario = await Usuario.findById(usuarioId);
    
    if (!usuario || !usuario.foto_url) {
      return res.status(404).json({ mensaje: 'Foto no encontrada' });
    }

    res.status(200).json({
      foto_url: usuario.foto_url
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener foto', error: error.message });
  }
};

// Obtener foto de estudiante
const getFotoEstudiante = async (req, res) => {
  try {
    const { estudianteId } = req.params;
    const estudiante = await Estudiante.findById(estudianteId);
    
    if (!estudiante || !estudiante.foto_url) {
      return res.status(404).json({ mensaje: 'Foto no encontrada' });
    }

    res.status(200).json({
      foto_url: estudiante.foto_url
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener foto', error: error.message });
  }
};

module.exports = {
  uploadFotoDocente,
  uploadFotoEstudiante,
  getFotoDocente,
  getFotoEstudiante
};
