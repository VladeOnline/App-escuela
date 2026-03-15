const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./src/config/database');

dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/auth', require('./src/routes/authRoutes'));

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ message: 'API Refuerzo Académico funcionando ✅' });
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});