const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./src/config/database');

dotenv.config({ path: path.join(__dirname, '.env') });

const app = express();

app.use(cors());
app.use(express.json({ limit: '6mb' }));

app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/estudiantes', require('./src/routes/estudianteRoutes'));
app.use('/api/ejercicios', require('./src/routes/EjercicioRoutes'));
app.use('/api/modulos', require('./src/routes/moduloRoutes'));
app.use('/api/contenidos', require('./src/routes/contenidoRoutes'));
app.use('/api/ranking', require('./src/routes/rankingRoutes'));

app.get('/', (req, res) => {
  res.json({ message: 'API Refuerzo Academico funcionando' });
});

const PORT = process.env.PORT || 3000;
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});
