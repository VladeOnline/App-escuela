const mongoose = require('mongoose');
const Materia = require('../models/materiaModel');

const obtenerMaterias = async (req, res) => {
  try {
    const { nombre, grado, activa } = req.query;
    const filtro = {};

    if (nombre) filtro.nombre = { $regex: nombre, $options: 'i' };
    if (grado) filtro.grado = Number(grado);
    if (activa !== undefined) filtro.activa = activa === 'true';

    const materias = await Materia.find(filtro).sort({ grado: 1, nombre: 1 });
    res.status(200).json(materias);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener materias', error: error.message });
  }
};

const crearMateria = async (req, res) => {
  try {
    const { nombre, grado } = req.body;

    if (!nombre || !grado) {
      return res.status(400).json({ message: 'nombre y grado son obligatorios' });
    }

    const nombreLimpio = String(nombre).trim();
    const gradoNumero = Number(grado);

    if (!nombreLimpio) {
      return res.status(400).json({ message: 'nombre no puede estar vacio' });
    }

    if (!Number.isInteger(gradoNumero) || gradoNumero < 1 || gradoNumero > 6) {
      return res.status(400).json({ message: 'grado debe ser un numero entero entre 1 y 6' });
    }

    const existe = await Materia.findOne({
      nombre: { $regex: `^${nombreLimpio}$`, $options: 'i' },
      grado: gradoNumero,
      activa: true
    });

    if (existe) {
      return res.status(409).json({ message: 'Ya existe una materia activa con ese nombre y grado' });
    }

    const materia = await Materia.create({
      nombre: nombreLimpio,
      grado: gradoNumero
    });

    res.status(201).json({
      message: 'Materia creada correctamente',
      materia
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al crear materia', error: error.message });
  }
};

const editarMateria = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, grado, activa } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'ID de materia invalido' });
    }

    const updates = {};
    if (nombre !== undefined) {
      const limpio = String(nombre).trim();
      if (!limpio) return res.status(400).json({ message: 'nombre no puede estar vacio' });
      updates.nombre = limpio;
    }
    if (grado !== undefined) {
      const g = Number(grado);
      if (!Number.isInteger(g) || g < 1 || g > 6) {
        return res.status(400).json({ message: 'grado debe ser un numero entero entre 1 y 6' });
      }
      updates.grado = g;
    }
    if (activa !== undefined) {
      if (typeof activa !== 'boolean') {
        return res.status(400).json({ message: 'activa debe ser true o false' });
      }
      updates.activa = activa;
    }

    const materia = await Materia.findByIdAndUpdate(id, updates, { new: true });
    if (!materia) return res.status(404).json({ message: 'Materia no encontrada' });

    res.status(200).json({
      message: 'Materia actualizada correctamente',
      materia
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al editar materia', error: error.message });
  }
};

module.exports = {
  obtenerMaterias,
  crearMateria,
  editarMateria
};
