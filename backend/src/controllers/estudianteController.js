const Estudiante = require('../models/studentModel');

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
    const { nombre, edad, grado } = req.body;
    const estudiante = new Estudiante({ nombre, edad, grado });
    await estudiante.save();
    res.status(201).json(estudiante);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear estudiante', error: error.message });
  }
};

const editarEstudiante = async (req, res) => {
  try {
    const estudiante = await Estudiante.findByIdAndUpdate(
      req.params.id,
      req.body,
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
    res.json({ message: 'Estudiante eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar estudiante', error: error.message });
  }
};

module.exports = { obtenerEstudiantes, crearEstudiante, editarEstudiante, eliminarEstudiante };