const mongoose = require('mongoose');
const Contenido = require('../models/contenidoModel');
const Ejercicio = require('../models/ejercicioModel');
const { registrarLog } = require('../utils/helpers');

// ─────────────────────────────────────────────
// Crear un contenido nuevo
// POST /api/contenidos
// ─────────────────────────────────────────────
const crearContenido = async (req, res) => {
  try {
    const { tipo_modulo, titulo, descripcion, grado } = req.body;

    if (!tipo_modulo || !titulo || !grado) {
      return res.status(400).json({
        mensaje: 'Faltan campos obligatorios: tipo_modulo, titulo, grado'
      });
    }

    const tiposValidos = ['lectura', 'escritura', 'matematicas'];
    if (!tiposValidos.includes(tipo_modulo)) {
      return res.status(400).json({
        mensaje: 'tipo_modulo debe ser: lectura, escritura o matematicas'
      });
    }

    if (grado < 1 || grado > 6) {
      return res.status(400).json({
        mensaje: 'El grado debe estar entre 1 y 6'
      });
    }

    const existe = await Contenido.findOne({
      tipo_modulo,
      titulo: titulo.trim(),
      grado
    });

    if (existe) {
      return res.status(400).json({
        mensaje: `Ya existe un contenido llamado "${titulo.trim()}" en ${tipo_modulo} grado ${grado}`
      });
    }

    const nuevoContenido = new Contenido({
      tipo_modulo,
      titulo: titulo.trim(),
      descripcion: descripcion ? descripcion.trim() : '',
      grado,
      activo: true
    });

    const contenidoGuardado = await nuevoContenido.save();

    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Creó contenido: "${titulo.trim()}" en ${tipo_modulo} grado ${grado}`);
    }

    res.status(201).json({
      mensaje: 'Contenido creado exitosamente',
      contenido: contenidoGuardado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al crear el contenido', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener contenidos (filtrable por tipo_modulo y/o grado)
// GET /api/contenidos?tipo_modulo=lectura&grado=2
// ─────────────────────────────────────────────
const obtenerContenidos = async (req, res) => {
  try {
    const { tipo_modulo, grado } = req.query;

    const filtro = { activo: true };
    if (tipo_modulo) filtro.tipo_modulo = tipo_modulo;
    if (grado)       filtro.grado = Number(grado);

    const contenidos = await Contenido.find(filtro).sort({ grado: 1, titulo: 1 });

    const contenidoIds = contenidos.map((c) => c._id);
    let totalesPorContenido = new Map();

    if (contenidoIds.length > 0) {
      const agregados = await Ejercicio.aggregate([
        {
          $match: {
            contenido_id: { $in: contenidoIds },
            activo: true
          }
        },
        {
          $group: {
            _id: '$contenido_id',
            total: { $sum: 1 }
          }
        }
      ]);

      totalesPorContenido = new Map(
        agregados.map((item) => [String(item._id), item.total])
      );
    }

    const contenidosConTotales = contenidos.map((contenido) => ({
      ...contenido.toObject(),
      totalEjercicios: totalesPorContenido.get(String(contenido._id)) ?? 0
    }));

    res.status(200).json({
      total: contenidos.length,
      contenidos: contenidosConTotales
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener contenidos', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Obtener un contenido por ID con su conteo de ejercicios
// GET /api/contenidos/:id
// ─────────────────────────────────────────────
const obtenerContenidoPorId = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de contenido inválido' });
    }

    const contenido = await Contenido.findById(id);
    if (!contenido) {
      return res.status(404).json({ mensaje: 'Contenido no encontrado' });
    }

    const Ejercicio = require('../models/ejercicioModel');
    const totalEjercicios = await Ejercicio.countDocuments({
      contenido_id: id,
      activo: true
    });

    res.status(200).json({
      contenido,
      totalEjercicios
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener el contenido', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Editar un contenido
// PUT /api/contenidos/:id
// ─────────────────────────────────────────────
const editarContenido = async (req, res) => {
  try {
    const { id } = req.params;
    const { titulo, descripcion, grado } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de contenido inválido' });
    }

    const actualizacion = {};
    if (titulo)                    actualizacion.titulo = titulo.trim();
    if (descripcion !== undefined) actualizacion.descripcion = descripcion.trim();
    if (grado) {
      if (grado < 1 || grado > 6) {
        return res.status(400).json({ mensaje: 'El grado debe estar entre 1 y 6' });
      }
      actualizacion.grado = grado;
    }

    const contenidoActualizado = await Contenido.findByIdAndUpdate(
      id,
      actualizacion,
      { new: true }
    );

    if (!contenidoActualizado) {
      return res.status(404).json({ mensaje: 'Contenido no encontrado' });
    }

    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Editó contenido: "${contenidoActualizado.titulo}"`);
    }

    res.status(200).json({
      mensaje: 'Contenido actualizado correctamente',
      contenido: contenidoActualizado
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al editar el contenido', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Eliminar un contenido
// DELETE /api/contenidos/:id
// ─────────────────────────────────────────────
const eliminarContenido = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de contenido inválido' });
    }

    const Ejercicio = require('../models/ejercicioModel');
    const tieneEjercicios = await Ejercicio.countDocuments({ contenido_id: id });

    if (tieneEjercicios > 0) {
      return res.status(400).json({
        mensaje: `No se puede eliminar porque tiene ${tieneEjercicios} ejercicio(s) asociado(s). Eliminá los ejercicios primero.`
      });
    }

    const contenido = await Contenido.findByIdAndDelete(id);
    if (!contenido) {
      return res.status(404).json({ mensaje: 'Contenido no encontrado' });
    }

    if (req.usuario?.id) {
      await registrarLog(req.usuario.id, `Eliminó contenido: "${contenido.titulo}"`);
    }

    res.status(200).json({ mensaje: 'Contenido eliminado correctamente' });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar el contenido', error: error.message });
  }
};

// ─────────────────────────────────────────────
// Activar o desactivar un contenido
// PATCH /api/contenidos/:id/toggle
// ─────────────────────────────────────────────
const toggleContenido = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ mensaje: 'ID de contenido inválido' });
    }

    const contenido = await Contenido.findById(id);
    if (!contenido) {
      return res.status(404).json({ mensaje: 'Contenido no encontrado' });
    }

    contenido.activo = !contenido.activo;
    await contenido.save();

    res.status(200).json({
      mensaje: contenido.activo ? 'Contenido activado' : 'Contenido desactivado',
      id: contenido._id,
      activo: contenido.activo
    });

  } catch (error) {
    res.status(500).json({ mensaje: 'Error al cambiar estado del contenido', error: error.message });
  }
};

module.exports = {
  crearContenido,
  obtenerContenidos,
  obtenerContenidoPorId,
  editarContenido,
  eliminarContenido,
  toggleContenido
};
