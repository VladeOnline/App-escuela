const Estudiante = require('../models/studentModel');
const Usuario = require('../models/userModel');
const bcrypt = require('bcryptjs');

const normalizeConditions = (value) => {
  if (!Array.isArray(value)) return [];
  return [...new Set(value
    .map((c) => String(c).trim())
    .filter((c) => c.length > 0))];
};

const isValidPhotoPayload = (value) => {
  if (value == null) return true;
  if (typeof value !== 'string') return false;
  if (!value.startsWith('data:image/')) return false;
  if (!value.includes(';base64,')) return false;
  return value.length <= 2_500_000;
};

const serializeEstudiante = (estudianteDoc) => {
  const estudiante = estudianteDoc.toObject ? estudianteDoc.toObject() : estudianteDoc;
  return {
    ...estudiante,
    foto_url: estudiante?.usuario_id?.foto_perfil_url ?? null,
  };
};

const obtenerEstudiantes = async (req, res) => {
  try {
    const { nombre, grado } = req.query;
    let filtro = { activo: true };

    if (nombre) filtro.nombre = { $regex: nombre, $options: 'i' };
    if (grado) filtro.grado = grado;

    const estudiantes = await Estudiante.find(filtro)
      .populate('usuario_id', 'foto_perfil_url');

    res.json(estudiantes.map(serializeEstudiante));
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener estudiantes', error: error.message });
  }
};

const crearEstudiante = async (req, res) => {
  try {
    const { nombre, edad, grado, conditions, foto_perfil_url: fotoPerfilUrl } = req.body;
    const normalizedConditions = normalizeConditions(conditions);

    if (!isValidPhotoPayload(fotoPerfilUrl)) {
      return res.status(400).json({
        message: 'La foto debe ser una imagen valida en formato data URL (data:image/...;base64,...)',
      });
    }

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
      rol: 'estudiante',
      foto_perfil_url: fotoPerfilUrl ?? null,
    });
    await usuario.save();

    const estudiante = new Estudiante({
      usuario_id: usuario._id,
      nombre,
      edad,
      grado,
      conditions: normalizedConditions,
    });
    await estudiante.save();

    const estudianteConFoto = await Estudiante.findById(estudiante._id)
      .populate('usuario_id', 'foto_perfil_url');

    res.status(201).json({
      estudiante: serializeEstudiante(estudianteConFoto),
      credenciales: {
        username,
        password: passwordPlana,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al crear estudiante', error: error.message });
  }
};

const editarEstudiante = async (req, res) => {
  try {
    const updates = { ...req.body };
    const fotoPerfilUrl = updates.foto_perfil_url;
    delete updates.foto_perfil_url;

    if (updates.conditions !== undefined) {
      updates.conditions = normalizeConditions(updates.conditions);
    }

    const estudianteAnterior = await Estudiante.findById(req.params.id);
    if (!estudianteAnterior) {
      return res.status(404).json({ message: 'Estudiante no encontrado' });
    }

    const estudiante = await Estudiante.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true }
    );

    const nextNombre = (updates.nombre ?? estudianteAnterior.nombre ?? '').trim();
    const nextEdad = updates.edad ?? estudianteAnterior.edad;
    let credencialesActualizadas = null;

    if (estudiante.usuario_id) {
      const usuarioUpdates = {};

      if (updates.nombre !== undefined) {
        usuarioUpdates.nombre = updates.nombre;
      }

      if (updates.nombre !== undefined || updates.edad !== undefined) {
        const username = nextNombre;
        const passwordPlana = String(nextNombre) + String(nextEdad);

        if (!username) {
          return res.status(400).json({ message: 'El nombre no puede estar vacio' });
        }

        const usuarioConMismoUsername = await Usuario.findOne({ username });
        if (
          usuarioConMismoUsername &&
          String(usuarioConMismoUsername._id) !== String(estudiante.usuario_id)
        ) {
          return res.status(400).json({
            message: 'Ya existe un estudiante con ese nombre',
          });
        }

        usuarioUpdates.username = username;
        usuarioUpdates.password_hash = await bcrypt.hash(passwordPlana, 10);
        credencialesActualizadas = {
          username,
          password: passwordPlana,
        };
      }

      if (fotoPerfilUrl !== undefined) {
        if (!isValidPhotoPayload(fotoPerfilUrl)) {
          return res.status(400).json({
            message: 'La foto debe ser una imagen valida en formato data URL (data:image/...;base64,...)',
          });
        }
        usuarioUpdates.foto_perfil_url = fotoPerfilUrl;
      }

      if (Object.keys(usuarioUpdates).length > 0) {
        await Usuario.findByIdAndUpdate(
          estudiante.usuario_id,
          usuarioUpdates,
          { new: true }
        );
      }
    }

    const estudianteConFoto = await Estudiante.findById(estudiante._id)
      .populate('usuario_id', 'foto_perfil_url');

    res.json({
      estudiante: serializeEstudiante(estudianteConFoto),
      credenciales: credencialesActualizadas,
    });
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





