const Gamificacion = require('./gamificacionModel');

const parseGrade = (value) => {
  const grade = Number.parseInt(value, 10);
  if (Number.isNaN(grade) || grade < 1 || grade > 6) {
    return null;
  }
  return grade;
};

const getRankingByGrade = async ({ grade, limit }) => {
  const parsedGrade = parseGrade(grade);
  if (parsedGrade == null) return [];

  const pipeline = [
    {
      $lookup: {
        from: 'estudiantes',
        localField: 'estudiante_id',
        foreignField: '_id',
        as: 'estudiante',
      },
    },
    { $unwind: '$estudiante' },
    {
      $match: {
        'estudiante.activo': true,
        'estudiante.grado': parsedGrade,
      },
    },
    {
      $lookup: {
        from: 'usuarios',
        localField: 'estudiante.usuario_id',
        foreignField: '_id',
        as: 'usuario',
      },
    },
    {
      $unwind: {
        path: '$usuario',
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $match: {
        $or: [{ usuario: null }, { 'usuario.activo': true }],
      },
    },
    {
      $project: {
        _id: 0,
        studentId: '$estudiante._id',
        name: '$estudiante.nombre',
        grade: '$estudiante.grado',
        points: '$puntos_total',
        photoUrl: '$usuario.foto_perfil_url',
      },
    },
    { $sort: { points: -1, name: 1 } },
  ];

  if (limit != null && limit > 0) {
    pipeline.push({ $limit: limit });
  }

  const rows = await Gamificacion.aggregate(pipeline);
  return rows.map((row, index) => ({
    studentId: row.studentId?.toString() ?? '',
    name: row.name ?? 'Estudiante',
    grade: row.grade ?? parsedGrade,
    points: row.points ?? 0,
    position: index + 1,
    photoUrl: row.photoUrl ?? null,
  }));
};

module.exports = { getRankingByGrade, parseGrade };
