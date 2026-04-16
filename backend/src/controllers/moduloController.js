const Contenido = require('../models/contenidoModel');

// ─────────────────────────────────────────────
// Los 3 módulos son fijos y nunca cambian.
// No se guardan en MongoDB — están hardcodeados aquí.
// El frontend los usa para saber qué icono y color mostrar.
// ─────────────────────────────────────────────
const MODULOS = [
  {
    id: 'lectura',
    tipo: 'lectura',
    label: 'Lectura',
    descripcion: 'Ejercicios de comprensión lectora e interpretación de textos'
  },
  {
    id: 'escritura',
    tipo: 'escritura',
    label: 'Escritura',
    descripcion: 'Ejercicios de ortografía, redacción y construcción de oraciones'
  },
  {
    id: 'matematicas',
    tipo: 'matematicas',
    label: 'Matemáticas',
    descripcion: 'Ejercicios numéricos y de razonamiento matemático'
  }
];

// ─────────────────────────────────────────────
// Obtener los 3 módulos disponibles
// GET /api/modulos
//
// El frontend llama esto al cargar la pantalla principal
// para saber qué módulos mostrar en el sidebar
// ─────────────────────────────────────────────
const obtenerModulos = async (req, res) => {
  try {
    res.status(200).json({
      total: MODULOS.length,
      modulos: MODULOS
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener módulos', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener un módulo por su tipo con sus contenidos agrupados por grado
// GET /api/modulos/:tipo
// Ejemplo: GET /api/modulos/lectura
//
// El frontend llama esto cuando el docente entra a un módulo.
// Devuelve el módulo con todos sus contenidos organizados por grado
// para mostrar las secciones "Primer grado", "Segundo grado", etc.
// ─────────────────────────────────────────────
const obtenerModuloPorTipo = async (req, res) => {
  try {
    const { tipo } = req.params;

    // Verificamos que el tipo sea uno de los 3 válidos
    const modulo = MODULOS.find(m => m.tipo === tipo);
    if (!modulo) {
      return res.status(404).json({
        mensaje: 'Módulo no encontrado. Debe ser: lectura, escritura o matematicas'
      });
    }

    // Buscamos todos los contenidos activos de este tipo de módulo
    // ordenados por grado para que el frontend los muestre en orden
    const contenidos = await Contenido.find({ tipo_modulo: tipo, activo: true })
      .sort({ grado: 1 }); // grado 1, 2, 3... en orden ascendente

    // Agrupamos los contenidos por grado para que Flutter pueda
    // construir las secciones fácilmente sin procesamiento extra
    // Resultado: { 1: [...], 2: [...], 3: [...] }
    const contenidosPorGrado = {};
    for (let grado = 1; grado <= 6; grado++) {
      // Para cada grado filtramos los contenidos que le pertenecen
      contenidosPorGrado[grado] = contenidos.filter(c => c.grado === grado);
    }

    res.status(200).json({
      modulo,
      contenidosPorGrado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener el módulo', error: error.message });
  }
};

module.exports = {
  obtenerModulos,
  obtenerModuloPorTipo
};