const Usuario = require('../models/userModel');
const Estudiante = require('../models/studentModel');
const Resultado = require('../models/resultadoModel');
const Gamificacion = require('../models/gamificacionModel');
const Ejercicio = require('../models/ejercicioModel');
const Contenido = require('../models/contenidoModel');
const Log = require('../models/logModel');

// ── Borrar todos los estudiantes ──────────────────────────────────────────────
const deleteAllStudents = async (req, res) => {
  try {
    // Primero, obtener todos los IDs de estudiantes
    const estudiantes = await Estudiante.find({}, '_id usuario_id');

    if (estudiantes.length === 0) {
      return res.status(200).json({ 
        mensaje: 'No hay estudiantes para borrar',
        eliminados: 0
      });
    }

    // Borrar resultados de esos estudiantes
    const estudianteIds = estudiantes.map(e => e._id);
    await Resultado.deleteMany({ estudiante_id: { $in: estudianteIds } });

    // Borrar gamificación
    await Gamificacion.deleteMany({ estudiante_id: { $in: estudianteIds } });

    // Borrar los estudiantes
    await Estudiante.deleteMany({ _id: { $in: estudianteIds } });

    // Borrar usuarios de tipo estudiante (mantener el docente)
    const usuarioIds = estudiantes.map(e => e.usuario_id);
    await Usuario.deleteMany({ _id: { $in: usuarioIds }, rol: 'estudiante' });

    return res.status(200).json({
      mensaje: 'Todos los estudiantes han sido eliminados',
      eliminados: estudiantes.length
    });
  } catch (error) {
    console.error('Error al borrar estudiantes:', error);
    return res.status(500).json({ 
      mensaje: 'Error al borrar estudiantes',
      error: error.message 
    });
  }
};

// ── Reiniciar sistema (borrar todo menos docente) ────────────────────────────
const resetSystem = async (req, res) => {
  try {
    // 1. Borrar todos los estudiantes y sus datos
    const estudiantes = await Estudiante.find({}, '_id usuario_id');
    const estudianteIds = estudiantes.map(e => e._id);

    // Borrar resultados
    await Resultado.deleteMany({ estudiante_id: { $in: estudianteIds } });

    // Borrar gamificación
    await Gamificacion.deleteMany({ estudiante_id: { $in: estudianteIds } });

    // Borrar estudiantes
    await Estudiante.deleteMany({});

    // Borrar usuarios de tipo estudiante
    await Usuario.deleteMany({ rol: 'estudiante' });

    // 2. Borrar todos los ejercicios
    await Ejercicio.deleteMany({});

    // 3. Borrar todos los contenidos
    await Contenido.deleteMany({});

    // 4. Borrar logs (opcional)
    if (Log) {
      await Log.deleteMany({});
    }

    return res.status(200).json({
      mensaje: 'Sistema reiniciado exitosamente',
      nota: 'Tu información como docente se mantiene. Todos los estudiantes, ejercicios, contenidos y resultados fueron eliminados.',
      estudiantesBorrados: estudiantes.length,
      datosLimpiados: {
        estudiantes: estudianteIds.length,
        ejercicios: 'todos',
        contenidos: 'todos'
      }
    });
  } catch (error) {
    console.error('Error al reiniciar sistema:', error);
    return res.status(500).json({ 
      mensaje: 'Error al reiniciar sistema',
      error: error.message 
    });
  }
};

module.exports = {
  deleteAllStudents,
  resetSystem
};
