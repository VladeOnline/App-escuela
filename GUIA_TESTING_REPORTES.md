## 🧪 GUÍA COMPLETA: CÓMO PROBAR LA INTEGRACIÓN BACKEND-FRONTEND

### ⏱️ Tiempo estimado: 15-20 minutos

---

## PASO 1️⃣: PREPARAR EL BACKEND (5 min)

### 1.1 Abre terminal en la carpeta backend

```bash
cd D:\Proyecto\ lV\App-escuela\backend
```

### 1.2 Instala dependencias (solo primera vez)

```bash
npm install
```

### 1.3 Inicia el servidor

```bash
npm start
```

**Deberías ver:**
```
✓ Servidor escuchando en puerto 3000
✓ Conexión a MongoDB: CONNECTED
```

**Si hay error de conexión a MongoDB:**
- Asegúrate que MongoDB esté corriendo localmente
- O verifica la conexión en `backend/src/config/`

### ✅ CHECKPOINT 1: Backend respondiendo en http://localhost:3000

---

## PASO 2️⃣: VERIFICAR ENDPOINTS CON POSTMAN (5 min)

### 2.1 Abre Postman

En la raíz del proyecto está: `Postman_Collection.json`

Import → File → Seleccionar `Postman_Collection.json` ✅

### 2.2 Testear 1 endpoint de reportes

En Postman, busca la carpeta **"REPORTES"**

#### Test: Obtener Reporte Individual

```
GET http://localhost:3000/api/reportes/individual/ESTUDIANTE_ID
```

**¿Cómo obtener ESTUDIANTE_ID?**

Primero, lista los estudiantes:
```
GET http://localhost:3000/api/estudiantes
```

Copia el `_id` de cualquier estudiante.

**Luego, reemplaza ESTUDIANTE_ID:**
```
GET http://localhost:3000/api/reportes/individual/[ID_COPIADO]
```

**Presiona Send** → Deberías recibir JSON como:

```json
{
  "estudiante": {
    "id": "...",
    "nombre": "Juan Pérez",
    "grado": 3
  },
  "resumen": {
    "totalEvaluaciones": 5,
    "promedio": 78
  },
  "resultados": [
    {
      "_id": "...",
      "puntuacion": 75,
      "fecha": "2026-04-05T10:30:00Z"
    }
  ]
}
```

### ✅ CHECKPOINT 2: Backend devuelve JSON válido

---

## PASO 3️⃣: CONFIGURAR FLUTTER (2 min)

### 3.1 Abre el proyecto en VS Code

```bash
cd D:\Proyecto\ lV\App-escuela
code .
```

### 3.2 Verifica que la URL sea correcta

**Archivo:** `lib/core/constants/app_constants.dart`

**Busca:**
```dart
static const apiBaseUrl = 'http://localhost:3000/api';
```

**Debe ser exactamente así** ✅

### ✅ CHECKPOINT 3: URL configurada correctamente

---

## PASO 4️⃣: CORRER FLUTTER (3 min)

### 4.1 Obtén dispositivo disponible

```bash
flutter devices
```

Deberías ver algo como:
```
• Chrome (web)    • web:...
• Windows (desktop) • windows
```

### 4.2 Ejecuta el app

**Opción A: En web (MÁS FÁCIL)**
```bash
flutter run -d chrome
```

**Opción B: En desktop**
```bash
flutter run -d windows
```

**Opción C: Si tienes Android emulator**
```bash
flutter run
```

### ⏳ Espera a que compile (puede tardar 1-2 minutos la primera vez)

**Deberías ver la pantalla de login** ✅

### ✅ CHECKPOINT 4: App Flutter corriendo

---

## PASO 5️⃣: NAVEGAR AL DASHBOARD (2 min)

### 5.1 Login

En la pantalla de login:
- **Username:** prof1 (o cualquier nombre)
- **Password:** 1234 (está en hardcode)
- **Rol:** Docente

Presiona **"Iniciar Sesión"** ✅

### ⏳ Espera a que cargue el dashboard

### ✅ CHECKPOINT 5: Dashboard visible

---

## PASO 6️⃣: ABRIR REPORTES (1 min)

### 6.1 En el dashboard, en el sidebar izquierdo

Busca el icono de **gráfica** o el menú con **"Reportes"**

**Debería estar en la opción 4 del menú** (después de Módulos de lectura/escritura)

Haz click → Abre la sección de Reportes ✅

### ✅ CHECKPOINT 6: Pestaña de Reportes abierta

---

## PASO 7️⃣: PROBAR REPORTE INDIVIDUAL (3 min)

### 7.1 Pestaña "Individual" (debería estar seleccionada por default)

Deberías ver:
- ✅ Campo de búsqueda "Buscar estudiante..."
- ✅ Lista de estudiantes debajo (si existen)

### 7.2 Busca o selecciona un estudiante

- Escribe el nombre en el campo de búsqueda → Se filtra la lista
- O directamente haz click en un estudiante

**Al seleccionar:**
- ✅ Aparece spinner de carga (CircularProgressIndicator)
- ✅ Desaparece después de 2-3 segundos
- ✅ Aparecen los datos del estudiante:
  ```
  [Nombre del estudiante] - Grado [X]
  Total Evaluaciones: [N]
  Promedio General: [X%]
  Aprobadas: [N]
  ```

- ✅ Tabla con todas las evaluaciones (Evaluación, Fecha, Puntuación, Estado, Intentos)

### ✅ CHECKPOINT 7: Datos reales del backend en UI

---

## PASO 8️⃣: PROBAR GRÁFICA DE PROGRESO (2 min)

### 8.1 Haz click en la pestaña **"Progreso"**

Repite el flujo:
- Busca/selecciona estudiante
- Espera a que cargue

### 8.2 Deberías ver una gráfica de barras:

```
80%  ████████
60%  ██████
75%  ███████
```

Con leyenda:
- 🟢 Verde: Excelente (80%+)
- 🟠 Naranja: Bueno (60-79%)
- 🔴 Rojo: Bajo (<60%)

### ✅ CHECKPOINT 8: Gráfica renderizada correctamente

---

## PASO 9️⃣: PROBAR REPORTE POR GRADO (2 min)

### 9.1 Haz click en la pestaña **"Por Grado"**

Deberías ver 6 botones:
```
[Grado 1] [Grado 2] [Grado 3] [Grado 4] [Grado 5] [Grado 6]
```

### 9.2 Haz click en **"Grado 3"** (o cualquiera con datos)

- ✅ Espera spinner
- ✅ Aparecen estadísticas:
  ```
  Grado 3
  Estudiantes: 5
  Evaluaciones: 12
  Promedio Grado: 72%
  ```

- ✅ Tabla con todos los resultados de ese grado

### ✅ CHECKPOINT 9: Datos por grado cargados

---

## PASO 🔟: PROBAR HISTORIAL (2 min)

### 10.1 Haz click en la pestaña **"Historial"**

Repite:
- Busca/selecciona estudiante

### 10.2 Deberías ver:

**Estadísticas arriba:**
```
Total Evaluaciones: [N]
Aprobadas: [N]
Promedio: [X%]
```

**Tabla con detalles:**
```
Evaluación | Materia | Fecha | Puntuación | Preguntas | Intento | Estado
Mate 101   | Math    | 09/04 | 85%        | 17/20     | 1       | Aprobado
```

### ✅ CHECKPOINT 10: Historial completo cargado

---

## 🧐 VERIFICACIÓN DE ERRORES (DEBUGGING)

### Si ves: "No se encontraron estudiantes"

**Solución:** Crea estudiantes primero
```
Dashboard → Estudiantes → Crear nuevo → Guarda datos
```

### Si ves spinner infinito

**Problema:** Backend no está respondiendo

**Solución:**
1. Verifica que `npm start` está corriendo en backend terminal
2. En Chrome DevTools:
   - F12 → Network tab
   - Recarga la página
   - Deberías ver peticiones GET a `localhost:3000/api/...`
   - Si devuelven 200 OK → Backend OK
   - Si no aparecen → Frontend no puede conectar

### Si ves: "Error al cargar reporte"

**Detalles en la pantalla:**
1. Mira el mensaje de error exacto
2. Abre Chrome DevTools → Console
3. Busca el error rojo
4. Comparte el error

---

## 📋 CHECKLIST FINAL

- [ ] Backend `npm start` ejecutando sin errores
- [ ] Postman GET /api/reportes/individual/{id} devuelve JSON
- [ ] Flutter corre sin errores de compilación
- [ ] Login funciona
- [ ] Pestaña Reportes visible en sidebar
- [ ] Tab Individual carga datos
- [ ] Tab Progreso muestra gráfica
- [ ] Tab Por Grado muestra datos
- [ ] Tab Historial muestra tabla completa
- [ ] Todos los datos coinciden entre Postman y Flutter

---

## 🎬 RESUMEN VIDEO MENTAL

```
1. Terminal 1: npm start (backend)
   ↓
2. Postman: GET /api/reportes/individual/[ID] ✅
   ↓
3. Terminal 2: flutter run -d chrome
   ↓
4. Browser abre → Login
   ↓
5. Dashboard → Reportes
   ↓
6. Selecciona estudiante → BOOM 💥 Datos aparecen en tiempo real
```

---

## 💡 TIPS ADICIONALES

### Para probar rápido sin login cada vez:
- Deja el browser abierto
- Los datos se cachean mientras no cierres la sesión

### Para ver requests en tiempo real:
```
Chrome F12 → Network → XHR
Verás todas las peticiones GET a /api/reportes/...
```

### Para resetear todo:
```bash
# Para el backend
Ctrl+C

# Limpia Flutter
flutter clean
flutter pub get
flutter run -d chrome
```

---

**¡Listo para testing! 🚀**
