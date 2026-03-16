const Usuario = require('../models/userModel');
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

    res.json({
      token,
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        rol: usuario.rol
      }
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
    res.status(201).json({ message: 'Docente registrado correctamente' });

  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
};

module.exports = { login, registrarDocente };