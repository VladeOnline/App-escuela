# 🚀 Guía Rápida - Backend API Escuela

## 📦 Instalación y Setup

### 1️⃣ Instalar dependencias
```bash
cd backend
npm install
```

### 2️⃣ Configurar variables de entorno
Crear archivo `.env` en la raíz de `backend/`:
```env
MONGODB_URI=mongodb+srv://usuario:contraseña@cluster.mongodb.net/basedatos
JWT_SECRET=un_secreto_fuerte_y_largo
PORT=3000
```

### 3️⃣ Iniciar servidor
```bash
npm start
# o para modo desarrollo (si tienes nodemon):
npm run dev
```

El servidor estará disponible en: `http://localhost:3000`

---

## ✅ Verificar que todo funciona

### Test básico
```bash
curl http://localhost:3000/
# Debe devolver: {"message":"API Refuerzo Académico funcionando ✅"}
```

---

## 📚 Documentación

| Archivo | Descripción |
|---------|-------------|
| [ENDPOINTS.md](./ENDPOINTS.md) | 📋 Documentación completa de todos los endpoints |
| [CAMBIOS.md](./CAMBIOS.md) | 📝 Resumen detallado de cambios implementados |
| [Postman_Collection.json](./Postman_Collection.json) | 🧪 Colección de Postman para testear |
| [test_endpoints.sh](./test_endpoints.sh) | 🔧 Script de pruebas en bash/curl |

---

## 🧪 Testear con Postman

### Importar colección
1. Abre Postman
2. Click en "Import"
3. Selecciona `Postman_Collection.json`
4. Automáticamente se importan todos los endpoints

### Configurar variables
En Postman, crear Environment con estas variables:
```
base_url = http://localhost:3000
token = (obtener del login)
estudiante_id = (ID válido en BD)
evaluacion_id = (ID válido en BD)
ejercicio_id = (ID válido en BD)
```

---

## 🔐 Flujo de Autenticación

### 1. Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "docente1", "password": "password123", "rol": "docente"}'
```

Respuesta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "usuario": {
    "id": "ObjectId",
    "nombre": "Docente Nombre",
    "rol": "docente"
  }
}
```

### 2. Usar el token en otros endpoints
```bash
curl -X GET http://localhost:3000/api/ejercicios/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

---

## 🎯 Casos de Uso Principales

### 📋 Caso 1: Ver instrucciones antes de evaluación
```bash
GET /api/reportes/evaluacion/{evaluacion_id}/instrucciones
```
Devuelve instrucciones, tiempo y datos necesarios (RF-36, RF-37)

### ✍️ Caso 2: Responder pregunta con retroalimentación
```bash
POST /api/ejercicios/responder
Body: {
  "estudiante_id": "...",
  "evaluacion_id": "...",
  "ejercicio_id": "...",
  "respuesta_dada": "respuesta"
}
```
Devuelve si es correcta, puntos y respuesta correcta (RF-24)

### 📊 Caso 3: Ver historial de evaluaciones
```bash
GET /api/reportes/historial/{estudiante_id}
```
Devuelve lista de todas las evaluaciones realizadas (RF-41)

### 🔄 Caso 4: Reiniciar puntuaciones (solo docentes/admins)
```bash
POST /api/reportes/admin/reiniciar/{estudiante_id}
Body: {"tipo_reinicio": "completo"}
```
Reinicia puntos del estudiante (RF-44)

---

## ⚠️ Notas importantes

- **Autenticación**: Todos los endpoints (excepto login/registrar) requieren token en header:
  ```
  Authorization: Bearer {token}
  ```

- **Permisos**: 
  - Endpoints de docentes requieren `soloAdminODocente`
  - Los estudiantes pueden responder ejercicios pero no crearlos

- **Validaciones**:
  - Todos los IDs son validados (ObjectId válido)
  - Las contraseñas se cifran con bcrypt automáticamente
  - Las respuestas se almacenan en BD para evitar trampas

---

## 🐛 Troubleshooting

### "Token no válido"
- Verifica que estés usando el token correcto del último login
- Revisa que el JWT_SECRET sea el mismo en .env

### "Acceso denegado"
- Solo docentes/admins pueden crear ejercicios, cambiar estados, etc.
- Los estudiantes solo pueden responder ejercicios

### "MongoDB connection failed"
- Verifica que MONGODB_URI es correcto
- Revisa que la BD está en línea
- Asegúrate de estar en la red/VPN requerida

### "No se envía retroalimentación al responder"
- El endpoint `/api/ejercicios/responder` compara CASE-INSENSITIVE
- Revisa que el ejercicio esté activo (activo: true)

---

## 📞 Contacto y Soporte

Para errores o preguntas, revisar:
1. [ENDPOINTS.md](./ENDPOINTS.md) - Documentación detallada
2. [CAMBIOS.md](./CAMBIOS.md) - Qué se cambió y por qué
3. Logs del servidor (`npm start`)

---

## ✨ Resumen de Requerimientos Implementados

| RF | Descripción | ✅ |
|---|---|---|
| RF-24 | Retroalimentación inmediata | ✅ |
| RF-25 | Contraseñas cifradas | ✅ |
| RF-26 | Logging de acciones | ✅ |
| RF-36 | Instrucciones antes evaluar | ✅ |
| RF-37 | Tiempo restante | ✅ |
| RF-41 | Historial evaluaciones | ✅ |
| RF-44 | Reiniciar puntuaciones | ✅ |

**Todos los requerimientos están 100% implementados ✅**

