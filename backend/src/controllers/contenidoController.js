const mongoose = require('mongoose');
const Contenido = require('../models/contenidoModel');
const Materia = require('../models/materiaModel');

const obtenerContenidos = async (req, res) => {
  try {
    const { materia_id, activo } = req.query;
    const filtro = {};

    if (materia_id) {
      if (!mongoose.Types.ObjectId.isValid(materia_id)) {
        return res.status(400).json({ message: 'materia_id invalido' });
      }
      filtro.materia_id = materia_id;
    }
    if (activo !== undefined) filtro.activo = activo === 'true';

    const contenidos = await Contenido.find(filtro)
      .populate('materia_id', 'nombre grado activa')
      .sort({ titulo: 1 });

    res.status(200).json(contenidos);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener contenidos', error: error.message });
  }
};

const crearContenido = async (req, res) => {
  try {
    const { materia_id, titulo, descripcion } = req.body;

    if (!materia_id || !titulo) {
      return res.status(400).json({ message: 'materia_id y titulo son obligatorios' });
    }

    if (!mongoose.Types.ObjectId.isValid(materia_id)) {
      return res.status(400).json({ message: 'materia_id invalido' });
    }

    const materia = await Materia.findById(materia_id);
    if (!materia) {
      return res.status(404).json({ message: 'La materia indicada no existe' });
    }
    if (!materia.activa) {
      return res.status(400).json({ message: 'No se puede crear contenido en una materia inactiva' });
    }

    const tituloLimpio = String(titulo).trim();
    if (!tituloLimpio) {
      return res.status(400).json({ message: 'titulo no puede estar vacio' });
    }

    const existe = await Contenido.findOne({
      materia_id,
      titulo: { $regex: `^${tituloLimpio}$`, $options: 'i' },
      activo: true
    });

    if (existe) {
      return res.status(409).json({ message: 'Ya existe un contenido activo con ese titulo en la materia' });
    }

    const contenido = await Contenido.create({
      materia_id,
      titulo: tituloLimpio,
      descripcion: descripcion ? String(descripcion).trim() : ''
    });

    res.status(201).json({
      message: 'Contenido creado correctamente',
      contenido
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al crear contenido', error: error.message });
  }
};

const editarContenido = async (req, res) => {
  try {
    const { id } = req.params;
    const { titulo, descripcion, activo } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID de contenido invalido' });
    }

    const updates = {};
    if (titulo !== undefined) {
      const limpio = String(titulo).trim();
      if (!limpio) return res.status(400).json({ message: 'titulo no puede estar vacio' });
      updates.titulo = limpio;
    }
    if (descripcion !== undefined) updates.descripcion = String(descripcion).trim();
    if (activo !== undefined) {
      if (typeof activo !== 'boolean') {
        return res.status(400).json({ message: 'activo debe ser true o false' });
      }
      updates.activo = activo;
    }

    const contenido = await Contenido.findByIdAndUpdate(id, updates, { new: true })
      .populate('materia_id', 'nombre grado activa');

    if (!contenido) return res.status(404).json({ message: 'Contenido no encontrado' });

    res.status(200).json({
      message: 'Contenido actualizado correctamente',
      contenido
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al editar contenido', error: error.message });
  }
};

module.exports = {
  obtenerContenidos,
  crearContenido,
  editarContenido
};
