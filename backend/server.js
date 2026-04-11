const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./src/config/database');

dotenv.config({ path: path.join(__dirname, '.env') });

const app = express();

app.use(cors());
app.use(express.json());
app.use('/api/reportes', require('./src/routes/reporteRotes'));
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/estudiantes', require('./src/routes/estudianteRoutes'));
app.use('/api/ejercicios', require('./src/routes/EjercicioRoutes'));

app.get('/', (req, res) => {
  res.json({ message: 'API Refuerzo Académico funcionando ✅' });
});

const PORT = process.env.PORT || 3000;
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});
