# CAMBIOS

## Resumen General

Se integraron avances de frontend y backend en una sola línea de trabajo:

- Integración de `feature/api-connection` y `feature/frontend-base`.
- Integración de `backend-rf-sprint1` con mejoras de reportes, seguridad y utilidades.

## Integración Frontend + API

- Login Flutter conectado al backend real usando `username`, `password` y `rol`.
- Eliminado acceso mock cuando fallaba backend.
- Repositorio API de estudiantes para listar, buscar, crear, editar y eliminar.
- Dashboard docente conectado a backend real.
- Integradas mejoras visuales de `feature/frontend-base`.
- Manejo de errores mejorado para mostrar mensajes del backend en Flutter.
- Creación de estudiantes devolviendo credenciales generadas de login.
- Ajuste backend para registrar `Usuario` y documento `Estudiante`.
- Ajuste de carga de variables de entorno desde `backend/.env`.

## Backend Sprint 1 (RF)

### Modelos actualizados

- `evaluacionModel`: campos `instrucciones` y `creado_en`.
- `resultadoModel`: `tiempo_utilizado`, `preguntas_correctas`, `total_preguntas` e índices.

### Middleware

- `soloAdmin()` para acceso exclusivo admin.
- `soloAdminODocente()` para acceso admin/docente.

### Utilidades

- `registrarLog(usuarioId, accion)`.
- `esObjectIdValido(id)`.
- `respuestaExitosa()` y `respuestaError()`.

### Controllers

- `ejercicioController`: logging en creación y retroalimentación estructurada (RF-24).
- `reportesController`:
  - `obtenerInstruccionesEvaluacion()` (RF-36, RF-37)
  - `obtenerHistorialEvaluaciones()` (RF-41)
  - `reiniciarPuntuacionesEstudiante()` (RF-44)

### Rutas

- `EjercicioRoutes`: middlewares de auth/rol en endpoints críticos.
- `reporteRotes`: rutas de instrucciones, historial y reinicio con auth.

## Requerimientos funcionales implementados

- RF-24: Retroalimentación inmediata.
- RF-25: Contraseñas cifradas.
- RF-26: Logging de acciones.
- RF-36: Instrucciones antes de evaluar.
- RF-37: Tiempo restante.
- RF-41: Historial de evaluaciones.
- RF-44: Reinicio de puntuaciones.

## Funcionando actualmente

- Login docente y estudiante contra backend.
- Registro/edición/eliminación de estudiantes con persistencia en MongoDB.
- Consulta y búsqueda de estudiantes.
- Navegación base del panel docente y vistas de módulos.
- Endpoints de reportes e historial disponibles.

## Notas

- `backend/.env` se mantiene fuera de commits (credenciales sensibles).
- Base de datos activa: `Sistema-Educativo`.
- Cambios orientados a compatibilidad hacia atrás.
