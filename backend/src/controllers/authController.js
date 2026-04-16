const Usuario = require('../models/userModel');
const Estudiante = require('../models/studentModel');
const Gamificacion = require('../models/gamificacionModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const MAX_IMAGE_BYTES = 4 * 1024 * 1024;

const isValidPhotoPayload = (value) => {
  if (typeof value !== 'string') return false;
  if (value.trim().length === 0) return false;
  if (!value.startsWith('data:image/')) return false;
  return value.length <= MAX_IMAGE_BYTES * 2;
};

const login = async (req, res) => {
  try {
    const { username, password, rol } = req.body;

    const usuario = await Usuario.findOne({ username, rol, activo: true });
    if (!usuario) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }

    const passwordValido = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordValido) {
      return res.status(401).json({ message: 'Contrasena incorrecta' });
    }

    const token = jwt.sign(
      { id: usuario._id, rol: usuario.rol },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    let estudianteData = null;
    if (usuario.rol === 'estudiante') {
      const estudiante = await Estudiante.findOne({
        usuario_id: usuario._id,
        activo: true,
      }).select('_id nombre grado');

      if (estudiante) {
        const gamificacion = await Gamificacion.findOne({
          estudiante_id: estudiante._id,
        }).select('puntos_total');

        estudianteData = {
          id: estudiante._id,
          nombre: estudiante.nombre,
          grado: estudiante.grado,
          puntos_total: gamificacion?.puntos_total ?? 0,
          foto_url: usuario.foto_perfil_url ?? null,
        };
      }
    }

    return res.json({
      token,
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        rol: usuario.rol,
        foto_perfil_url: usuario.foto_perfil_url ?? null,
      },
      estudiante: estudianteData,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

const registrarDocente = async (req, res) => {
  try {
    const { nombre, username, password } = req.body;

    const existe = await Usuario.findOne({ username });
    if (existe) {
      return res.status(400).json({ message: 'El usuario ya existe' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const usuario = new Usuario({
      nombre,
      username,
      password_hash,
      rol: 'docente',
    });

    await usuario.save();
    return res.status(201).json({ message: 'Docente registrado correctamente', usuario });
  } catch (error) {
    return res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

const registrarEstudiante = async (req, res) => {
  try {
    const { nombre, username, password, edad, grado } = req.body;

    const existe = await Usuario.findOne({ username });
    if (existe) {
      return res.status(400).json({ message: 'El usuario ya existe' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const usuario = new Usuario({
      nombre,
      username,
      password_hash,
      rol: 'estudiante',
    });

    await usuario.save();

    const estudiante = new Estudiante({
      usuario_id: usuario._id,
      nombre,
      edad,
      grado,
    });

    await estudiante.save();

    return res.status(201).json({
      message: 'Estudiante registrado correctamente',
      usuario,
      estudiante,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

const actualizarFotoPerfil = async (req, res) => {
  try {
    const { id } = req.usuario;
    const { foto_perfil_url: fotoPerfilUrl } = req.body;

    if (!isValidPhotoPayload(fotoPerfilUrl)) {
      return res.status(400).json({
        message: 'La foto debe ser una imagen valida en formato data URL (data:image/...;base64,...)',
      });
    }

    const usuarioActualizado = await Usuario.findByIdAndUpdate(
      id,
      { foto_perfil_url: fotoPerfilUrl },
      { new: true, runValidators: true }
    ).select('_id nombre rol foto_perfil_url');

    if (!usuarioActualizado) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    return res.json({
      message: 'Foto de perfil actualizada correctamente',
      usuario: {
        id: usuarioActualizado._id,
        nombre: usuarioActualizado.nombre,
        rol: usuarioActualizado.rol,
        foto_perfil_url: usuarioActualizado.foto_perfil_url,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

module.exports = { login, registrarDocente, registrarEstudiante, actualizarFotoPerfil };


