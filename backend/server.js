const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./src/config/database');

dotenv.config({ path: path.join(__dirname, '.env') });

const app = express();

app.use(cors());
app.use(express.json({ limit: '5mb' }));
app.use(express.urlencoded({ extended: true, limit: '5mb' }));

app.use('/api/reportes', require('./src/routes/reporteRotes'));
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/estudiantes', require('./src/routes/estudianteRoutes'));
app.use('/api/ejercicios', require('./src/routes/EjercicioRoutes'));
app.use('/api/modulos', require('./src/routes/moduloRoutes'));
app.use('/api/contenidos', require('./src/routes/contenidoRoutes'));
app.use('/api/ranking', require('./src/routes/rankingRoutes'));
app.use('/api/admin', require('./src/routes/adminRoutes'));

app.get('/', (req, res) => {
  res.json({ message: 'API Refuerzo Academico funcionando' });
});

app.use((err, req, res, next) => {
  if (err?.type === 'entity.too.large') {
    return res.status(413).json({
      message: 'La imagen excede el tamaño máximo permitido (5 MB de payload).',
    });
  }
  return next(err);
});

const PORT = process.env.PORT || 3000;
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});
