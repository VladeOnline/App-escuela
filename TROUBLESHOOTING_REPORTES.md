## 🔧 TROUBLESHOOTING: SOLUCIONES RÁPIDAS

### Problema 1: "Cannot reach backend"

**Síntomas:**
- Spinner cargando infinitamente
- En DevTools Console: "Connection refused" o "Failed to fetch"

**Solución:**

```bash
# Terminal 1: Verifica que backend esté corriendo
cd backend
npm start

# Deberías ver:
# ✓ Server listening on port 3000
# ✓ MongoDB connection established
```

Si ves error de MongoDB:
```bash
# En Windows, asegúrate que MongoDB esté corriendo
# O verifica en Services (services.msc) que esté activo
```

---

### Problema 2: "No data appears after selection"

**Síntomas:**
- Selecciona estudiante
- Spinner desaparece
- Pero no hay datos

**Diagnosis:**

1. **Abre Chrome DevTools (F12)**
2. **Tab "Network"**
3. **Selecciona estudiante nuevamente**
4. **Busca petición GET a `reportes/individual/...`**

**Casos:**

#### Caso A: Network muestra 200 OK pero no hay datos
```
→ El backend respondió, pero el JSON es inválido
→ Abre Response y verifica formato

Debería ser:
{
  "estudiante": { "id": "...", "nombre": "...", "grado": 3 },
  "resumen": { "totalEvaluaciones": 5, "promedio": 75 },
  "resultados": [...]
}
```

#### Caso B: Network muestra 404 Not Found
```
→ El estudiante no existe o el ID es inválido

Solución:
1. Ve a Postman
2. GET http://localhost:3000/api/estudiantes
3. Copia un ID válido
4. Prueba manualmente en Postman:
   GET http://localhost:3000/api/reportes/individual/[ID]
```

#### Caso C: Network muestra 500 Internal Server Error
```
→ Error en el backend

Solución:
1. Mira la terminal del backend
2. Debería mostrar el error
3. Soluciona el error en reportesController.js
4. Reinicia con npm start
```

---

### Problema 3: "Login no funciona"

**Solución rápida:**
```
Username: prof1 (o cualquier texto)
Password: 1234 (hardcodeado)
Rol: Docente
```

Si sigue sin funcionar:
```bash
# Resetea el estado de Flutter
flutter clean
flutter pub get
flutter run -d chrome
```

---

### Problema 4: "Gráfica no se ve / está vacía"

**Significa:**
- No hay datos de progreso en la BD

**Solución:**
1. En el dashboard, ve a **Módulos de Lectura**
2. Completa una evaluación con un estudiante
3. Esto genera datos en la colección `resultados`
4. Regresa a Reportes → Progreso → Verás la gráfica

---

### Problema 5: "Reporte por Grado dice 'No hay estudiantes'"

**Solución:**
1. Ve a Dashboard → Estudiantes
2. Crea estudiantes (mínimo 1)
3. Asegúrate que tengan un grado (1-6)
4. Regresa a Reportes → Por Grado

---

## 🔍 DEBUGGING AVANZADO

### Ver todas las requests HTTP

```javascript
// En Chrome Console, copia y pega esto:
fetch('http://localhost:3000/api/reportes/individual/[ESTUDIANTE_ID]')
  .then(r => r.json())
  .then(d => console.log(JSON.stringify(d, null, 2)))
  .catch(e => console.error('Error:', e))
```

Reemplaza `[ESTUDIANTE_ID]` con un ID real.

Deberías ver la respuesta completa en la console.

---

### Ver estado actual del Notifier

En el código de `individual_report_page.dart`, agrega temporalmente:

```dart
print('Estado: ${_reportNotifier.state}');
print('Error: ${_reportNotifier.error}');
print('Report: ${_reportNotifier.report}');
```

Y verás en la terminal de Flutter todos los detalles.

---

### Verificar que la URL es correcta

```dart
// En app_constants.dart, verifica:
static const apiBaseUrl = 'http://localhost:3000/api';

// DEBE SER EXACTAMENTE ESTO:
// - http (no https)
// - localhost:3000
// - /api al final

// INCORRECTO:
// http://127.0.0.1:3000/api  ❌ (usa 127.0.0.1 en lugar de localhost)
// http://localhost:3000      ❌ (sin /api)
// https://localhost:3000/api ❌ (https en lugar de http)
```

---

## 📊 TESTEAR CON CURL (sin Postman)

Si prefieres terminal:

```bash
# Obtener lista de estudiantes
curl http://localhost:3000/api/estudiantes

# Obtener reporte individual
curl http://localhost:3000/api/reportes/individual/ESTUDIANTE_ID

# Obtener reporte por grado
curl http://localhost:3000/api/reportes/grado/3

# Obtener progreso
curl http://localhost:3000/api/reportes/progreso/ESTUDIANTE_ID

# Obtener historial
curl http://localhost:3000/api/reportes/historial/ESTUDIANTE_ID
```

---

## ⚡ RESETEAR TODO

Si todo está roto:

```bash
# 1. Para todos los procesos
Ctrl+C en todas las terminales

# 2. Limpia Flutter
flutter clean

# 3. Reinstala dependencias
flutter pub get

# 4. Resetea base de datos (opcional, si usas MongoDB local)
# Elimina todos los datos y empieza de cero

# 5. Reinicia backend
cd backend
npm start

# 6. En otra terminal, reinicia Flutter
flutter run -d chrome
```

---

## 📱 TESTEAR EN MÓVIL/EMULADOR

Si quieres probar en Android emulator en lugar de web:

```bash
# 1. Cambia la URL backend para que apunte a tu IP local
# En app_constants.dart:
static const apiBaseUrl = 'http://192.168.X.X:3000/api';
// Reemplaza 192.168.X.X con tu IP de la máquina

# 2. Ejecuta Flutter
flutter run

# 3. Abre DevTools
flutter pub global run devtools
```

**Nota:** Mientras desarrolles localmente, usa `http://localhost:3000/api` para web.

---

## ✅ CONFIRMACIÓN DE ÉXITO

Cuando TODO esté funcionando:

1. ✅ Backend devuelve JSON en Postman
2. ✅ Flutter corre sin errores
3. ✅ Login funciona
4. ✅ Reportes → Individual: Se carga dato de estudiante
5. ✅ Reportes → Progreso: Se ve gráfica
6. ✅ Reportes → Por Grado: Se cargan estadísticas
7. ✅ Reportes → Historial: Se ve tabla completa

**LISTO PARA PRODUCCIÓN** ✅

---
