const Estudiante = require('../models/studentModel');
const Usuario = require('../models/userModel');
const bcrypt = require('bcryptjs');

const normalizeConditions = (value) => {
  if (!Array.isArray(value)) return [];
  return [...new Set(value
    .map((c) => String(c).trim())
    .filter((c) => c.length > 0))];
};

const obtenerEstudiantes = async (req, res) => {
  try {
    const { nombre, grado } = req.query;
    let filtro = { activo: true };

    if (nombre) filtro.nombre = { $regex: nombre, $options: 'i' };
    if (grado) filtro.grado = grado;

    const estudiantes = await Estudiante.find(filtro);
    res.json(estudiantes);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener estudiantes', error: error.message });
  }
};

const crearEstudiante = async (req, res) => {
  try {
    const { nombre, edad, grado, conditions } = req.body;
    const normalizedConditions = normalizeConditions(conditions);

    const username = nombre.trim();
    const passwordPlana = `${nombre.trim()}${edad}`;
    const password_hash = await bcrypt.hash(passwordPlana, 10);

    const usuarioExiste = await Usuario.findOne({ username });
    if (usuarioExiste) {
      return res.status(400).json({ message: 'Ya existe un estudiante con ese nombre' });
    }

    const usuario = new Usuario({
      nombre,
      username,
      password_hash,
      rol: 'estudiante'
    });
    await usuario.save();

    const estudiante = new Estudiante({
      usuario_id: usuario._id,
      nombre,
      edad,
      grado,
      conditions: normalizedConditions
    });
    await estudiante.save();

    res.status(201).json({
      estudiante,
      credenciales: {
        username,
        password: passwordPlana
      }
    });

  } catch (error) {
    res.status(500).json({ message: 'Error al crear estudiante', error: error.message });
  }
};

const editarEstudiante = async (req, res) => {
  try {
    const updates = { ...req.body };
    if (updates.conditions !== undefined) {
      updates.conditions = normalizeConditions(updates.conditions);
    }

    const estudiante = await Estudiante.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true }
    );
    if (!estudiante) return res.status(404).json({ message: 'Estudiante no encontrado' });
    res.json(estudiante);
  } catch (error) {
    res.status(500).json({ message: 'Error al editar estudiante', error: error.message });
  }
};

const eliminarEstudiante = async (req, res) => {
  try {
    const estudiante = await Estudiante.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );
    if (!estudiante) return res.status(404).json({ message: 'Estudiante no encontrado' });

    // Mantiene sincronizado el estado del usuario asociado.
    if (estudiante.usuario_id) {
      await Usuario.findByIdAndUpdate(
        estudiante.usuario_id,
        { activo: false },
        { new: true }
      );
    }

    res.json({
      message: 'Estudiante eliminado correctamente',
      estudiante_id: estudiante._id,
      usuario_id: estudiante.usuario_id,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar estudiante', error: error.message });
  }
};

module.exports = { obtenerEstudiantes, crearEstudiante, editarEstudiante, eliminarEstudiante };
