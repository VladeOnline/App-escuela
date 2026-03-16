const jwt = require('jsonwebtoken');

const verificarToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token no proporcionado' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido' });
  }
};

const soloDocente = (req, res, next) => {
  if (req.usuario.rol !== 'docente') {
    return res.status(403).json({ message: 'Acceso solo para docentes' });
  }
  next();
};

module.exports = { verificarToken, soloDocente };