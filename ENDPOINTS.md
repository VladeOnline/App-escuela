# 📋 DOCUMENTACIÓN DE ENDPOINTS - BACKEND ESCUELA

Documentación completa de todos los endpoints implementados con los requerimientos funcionales.

---

## 🔐 AUTENTICACIÓN

### Login
```
POST /api/auth/login
```
**Body:**
```json
{
  "username": "string",
  "password": "string",
  "rol": "docente|estudiante"
}
```
**Respuesta (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "usuario": {
    "id": "ObjectId",
    "nombre": "string",
    "rol": "docente|estudiante"
  }
}
```

### Registrar Docente
```
POST /api/auth/registrar
```
**Body:**
```json
{
  "nombre": "string",
  "username": "string (único)",
  "password": "string"
}
```
**Respuesta (201):**
```json
{
  "message": "Docente registrado correctamente"
}
```

**Características:**
- ✅ RF-25: Contraseñas cifradas con bcryptjs (10 rondas)
- ✅ En login se compara contraseña con hash
- ✅ No se guardan contraseñas en texto plano

---

## 📝 EJERCICIOS

Todos los endpoints de ejercicios requieren token de autenticación:
```
Authorization: Bearer <token>
```

### Crear Ejercicio (RF-10)
```
POST /api/ejercicios/
```
**Permisos:** Solo docentes/admins

**Body:**
```json
{
  "contenido_id": "ObjectId",
  "evaluacion_id": "ObjectId",
  "pregunta": "string",
  "opciones": ["opción1", "opción2", "opción3"],
  "respuesta_correcta": "opción1",
  "dificultad": "facil|medio|dificil"
}
```
**Respuesta (201):**
```json
{
  "mensaje": "Ejercicio creado exitosamente",
  "ejercicio": { /* datos */ }
}
```

**Características:**
- ✅ RF-26: Registra en log la acción realizada
- ✅ Valida que respuesta_correcta esté en opciones
- ✅ Normaliza dificultad a minúsculas

---

### Cambiar Estado (Activar/Desactivar) - RF-12
```
PATCH /api/ejercicios/:id/estado
```
**Permisos:** Solo docentes/admins

**Body:**
```json
{
  "activo": true|false
}
```
**Respuesta (200):**
```json
{
  "mensaje": "Ejercicio activado/desactivado correctamente",
  "ejercicio": { /* datos */ }
}
```

---

### Cambiar Dificultad - RF-11
```
PATCH /api/ejercicios/:id/dificultad
```
**Permisos:** Solo docentes/admins

**Body:**
```json
{
  "dificultad": "facil|medio|dificil"
}
```
**Respuesta (200):**
```json
{
  "mensaje": "Dificultad actualizada correctamente",
  "ejercicio": { /* datos */ }
}
```

---

### Obtener Ejercicios
```
GET /api/ejercicios/
```
**Respuesta (200):**
```json
[
  { /* ejercicio 1 */ },
  { /* ejercicio 2 */ }
]
```

---

### Responder Pregunta (RF-24, RF-13, RF-14)
```
POST /api/ejercicios/responder
```
**Body:**
```json
{
  "estudiante_id": "ObjectId",
  "evaluacion_id": "ObjectId",
  "ejercicio_id": "ObjectId",
  "respuesta_dada": "string"
}
```
**Respuesta (201):**
```json
{
  "mensaje": "Respuesta registrada",
  "retroalimentacion": {
    "esCorrecta": true|false,
    "puntosObtenidos": 10|20|30,
    "respuestaCorrecta": "respuesta correcta",
    "explicacion": "✅ ¡Respuesta correcta!" o "❌ Respuesta incorrecta..."
  }
}
```

**Características:**
- ✅ RF-24: Devuelve retroalimentación inmediata
- ✅ Devuelve si es correcta o no
- ✅ Devuelve puntos obtenidos
- ✅ Devuelve respuesta correcta si falló
- ✅ Puntos: facil=10, medio=20, dificil=30

---

### Finalizar Evaluación (RF-13, RF-14)
```
POST /api/ejercicios/finalizar
```
**Body:**
```json
{
  "estudiante_id": "ObjectId",
  "evaluacion_id": "ObjectId"
}
```
**Respuesta (201):**
```json
{
  "mensaje": "Evaluación finalizada",
  "resumen": {
    "notaFinal": 85,
    "respuestasCorrectas": 17,
    "totalPreguntas": 20,
    "intento": 1,
    "intentosRestantes": 2,
    "aprobado": true
  }
}
```

**Características:**
- ✅ Calcula nota en servidor (no confiable en cliente)
- ✅ El backend valida que no se exceda intentos_max
- ✅ Limpia las respuestas temporales

---

### Obtener Resultados por Evaluación
```
GET /api/ejercicios/resultados/:id
```
**Permisos:** Solo docentes/admins

**Respuesta (200):**
```json
{
  "total": 25,
  "resultados": [
    {
      "_id": "ObjectId",
      "estudiante_id": { "nombre": "Juan", "grado": 10 },
      "puntuacion": 85,
      "intentos": 1,
      "fecha": "2024-03-31T12:00:00.000Z"
    }
  ]
}
```

---

## 📊 REPORTES

### Obtener Instrucciones de Evaluación (RF-36, RF-37)
```
GET /api/reportes/evaluacion/:evaluacion_id/instrucciones
```
**Respuesta (200):**
```json
{
  "mensaje": "Instrucciones y datos de la evaluación",
  "evaluacion": {
    "id": "ObjectId",
    "titulo": "Evaluación de Matemáticas",
    "instrucciones": "Resuelve los problemas siguiendo el procedimiento...",
    "tiempo_limite": 45,
    "intentos_max": 3,
    "timestamp_inicio": "2024-03-31T12:00:00.000Z"
  }
}
```

**Características:**
- ✅ RF-36: Devuelve instrucciones antes de iniciar evaluación
- ✅ RF-37: Devuelve tiempo_limite para que frontend haga cuenta regresiva
- ✅ timestamp_inicio para calcular tiempo utilizado

---

### Obtener Historial de Evaluaciones (RF-41)
```
GET /api/reportes/historial/:estudiante_id
```
**Respuesta (200):**
```json
{
  "mensaje": "Historial de evaluaciones",
  "estudiante": {
    "id": "ObjectId",
    "nombre": "Juan Pérez",
    "grado": 10
  },
  "estadisticas": {
    "total_evaluaciones": 5,
    "evaluaciones_aprobadas": 4,
    "promedio_general": 82
  },
  "historial": [
    {
      "resultado_id": "ObjectId",
      "evaluacion_id": "ObjectId",
      "evaluacion_nombre": "Evaluación Parcial 1",
      "materia": "Matemáticas",
      "puntuacion": 90,
      "preguntas_correctas": 18,
      "total_preguntas": 20,
      "intento": 1,
      "fecha": "2024-03-31T12:00:00.000Z",
      "aprobado": true
    }
  ]
}
```

**Características:**
- ✅ RF-41: Lista de resultados con detalles
- ✅ Incluye evaluacion_id, puntuacion, fecha, intento
- ✅ Calcula estadísticas

---

### Reiniciar Puntuaciones (RF-44)
```
POST /api/reportes/admin/reiniciar/:estudiante_id
```
**Permisos:** Solo docentes/admins

**Body:**
```json
{
  "tipo_reinicio": "completo|por_evaluacion|por_materia",
  "evaluacion_id": "ObjectId (opcional, si tipo_reinicio=por_evaluacion)",
  "materia_id": "ObjectId (opcional, si tipo_reinicio=por_materia)"
}
```
**Respuesta (200):**
```json
{
  "mensaje": "Puntuaciones reiniciadas correctamente",
  "accion": "Reinició completamente los puntos del estudiante Juan Pérez",
  "estudiante": {
    "id": "ObjectId",
    "nombre": "Juan Pérez"
  },
  "gamificacion_actualizada": {
    "puntos_total": 0,
    "nivel": 1,
    "insignias": []
  }
}
```

**Características:**
- ✅ RF-44: Reinicia puntuaciones cuando docente lo requiere
- ✅ RF-26: Registra la acción en el log
- ✅ Solo docentes/admins pueden hacer esto
- ✅ Soporta reinicio por tipo: completo, por evaluación, por materia
- ✅ Reinicia también gamificación

---

### Obtener Reporte Individual (RF-17)
```
GET /api/reportes/individual/:estudianteId
```
**Respuesta (200):**
```json
{
  "estudiante": {
    "id": "ObjectId",
    "nombre": "Juan Pérez",
    "grado": 10
  },
  "resumen": {
    "totalEvaluaciones": 8,
    "promedio": 82
  },
  "resultados": [ /* array de resultados */ ]
}
```

---

### Obtener Reporte por Grado (RF-18)
```
GET /api/reportes/grado/:grado
```
**Respuesta (200):**
```json
{
  "grado": 10,
  "totalEstudiantes": 35,
  "totalResultados": 245,
  "promedioGrado": 78,
  "resultados": [ /* array de resultados */ ]
}
```

---

### Obtener Datos para Gráficas de Progreso (RF-16)
```
GET /api/reportes/progreso/:estudianteId
```
**Respuesta (200):**
```json
{
  "estudiante": {
    "id": "ObjectId",
    "nombre": "Juan Pérez",
    "grado": 10
  },
  "grafica": {
    "labels": ["Evaluación 1", "Evaluación 2", "Evaluación 3"],
    "data": [75, 82, 90]
  },
  "resultados": [ /* array de resultados */ ]
}
```

---

## 📚 ESTUDIANTES

### Obtener Estudiantes
```
GET /api/estudiantes/
```

### Crear Estudiante
```
POST /api/estudiantes/
```
**Permisos:** Solo docentes

### Editar Estudiante
```
PUT /api/estudiantes/:id
```
**Permisos:** Solo docentes

### Eliminar Estudiante
```
DELETE /api/estudiantes/:id
```
**Permisos:** Solo docentes

---

## 🔐 CÓDIGOS HTTP

| Código | Significado |
|--------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado |
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - No autenticado |
| 403 | Forbidden - Acceso denegado |
| 404 | Not Found - Recurso no encontrado |
| 500 | Server Error - Error del servidor |

---

## 📦 VARIABLES DE ENTORNO

Crear archivo `.env` en la raíz del backend:

```env
MONGODB_URI=mongodb+srv://usuario:contraseña@cluster.mongodb.net/basedatos
JWT_SECRET=tu_clave_secreto_fuerte_aqui
PORT=3000
```

---

## 🧪 TESTING CON CURL

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "docente1",
    "password": "password123",
    "rol": "docente"
  }'
```

### Crear Ejercicio
```bash
curl -X POST http://localhost:3000/api/ejercicios/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "contenido_id": "ObjectId",
    "evaluacion_id": "ObjectId",
    "pregunta": "¿Cuál es 2+2?",
    "opciones": ["3", "4", "5"],
    "respuesta_correcta": "4",
    "dificultad": "facil"
  }'
```

### Responder Pregunta
```bash
curl -X POST http://localhost:3000/api/ejercicios/responder \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "estudiante_id": "ObjectId",
    "evaluacion_id": "ObjectId",
    "ejercicio_id": "ObjectId",
    "respuesta_dada": "4"
  }'
```

---

## ✅ REQUERIMIENTOS CUMPLIDOS

- ✅ **RF-24**: Retroalimentación inmediata con respuesta correcta/incorrecta, puntos y explicación
- ✅ **RF-25**: Contraseñas cifradas con bcrypt, comparación en login
- ✅ **RF-26**: Logging de acciones administrativas (crear ejercicio, reiniciar puntuaciones)
- ✅ **RF-36**: Instrucciones antes de evaluar + campo en modelo
- ✅ **RF-37**: Tiempo límite devuelto para cuenta regresiva en frontend
- ✅ **RF-41**: Historial completo de evaluaciones con detalles
- ✅ **RF-44**: Reinicio de puntuaciones solo para docentes/admins

---

## 📝 NOTAS

- No rompe código existente
- Sigue estructura REST
- Validaciones de ObjectId
- Manejo de errores con try/catch
- Respuestas JSON claro y estructurado
- Middleware de autenticación en rutas críticas
