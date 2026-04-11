const Usuario = require('../models/userModel');
const Estudiante = require('../models/studentModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  try {
    const { username, password, rol } = req.body;

    const usuario = await Usuario.findOne({ username, rol, activo: true });
    if (!usuario) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }

    const passwordValido = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordValido) {
      return res.status(401).json({ message: 'Contraseña incorrecta' });
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
        estudianteData = {
          id: estudiante._id,
          nombre: estudiante.nombre,
          grado: estudiante.grado,
          puntos_total: 0,
          foto_url: null,
        };
      }
    }

    res.json({
      token,
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        rol: usuario.rol,
      },
      estudiante: estudianteData,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
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
      rol: 'docente'
    });

    await usuario.save();
    res.status(201).json({ message: 'Docente registrado correctamente', usuario });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
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
      rol: 'estudiante'
    });

    await usuario.save();

    const estudiante = new Estudiante({
      usuario_id: usuario._id,
      nombre,
      edad,
      grado
    });

    await estudiante.save();

    res.status(201).json({
      message: 'Estudiante registrado correctamente',
      usuario,
      estudiante
    });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

module.exports = { login, registrarDocente, registrarEstudiante };
