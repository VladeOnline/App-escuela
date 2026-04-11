## ⚡ QUICK START: COMANDOS COPY-PASTE

### TERMINAL 1: BACKEND

```bash
cd D:\Proyecto\ lV\App-escuela\backend
npm start
```

**Espera a ver:**
```
✓ Server listening on port 3000
✓ MongoDB connection established
```

---

### TERMINAL 2: FLUTTER

```bash
cd D:\Proyecto\ lV\App-escuela
flutter run -d chrome
```

**Espera a que se abra Chrome automáticamente**

---

### EN CHROME (el browser que abrió Flutter)

**Paso 1: Login**
```
Username: prof1
Password: 1234
Rol: Docente
Click: Iniciar Sesión
```

**Paso 2: Navega al Reportes**
- Sidebar izquierdo
- 4ta opción: "Reportes" (icono de gráfica)
- Click

**Paso 3: Prueba cada tab**

**Tab 1 - Individual:**
1. Escribe nombre de estudiante en búsqueda
2. Click en estudiante
3. Espera 2 segundos
4. ✅ Datos aparecen

**Tab 2 - Progreso:**
1. Escribe nombre de estudiante
2. Click en estudiante
3. ✅ Gráfica aparece

**Tab 3 - Por Grado:**
1. Click en botón "Grado 3"
2. ✅ Datos de grado aparecen

**Tab 4 - Historial:**
1. Escribe nombre de estudiante
2. Click en estudiante
3. ✅ Tabla histórica aparece

---

## 🎯 QUICK VERIFICATION

### Verificar Backend
```bash
# En navegador o Postman:
GET http://localhost:3000/api/estudiantes
```
**Deberías recibir:** JSON con lista de estudiantes

### Verificar Reporte Individual
```bash
GET http://localhost:3000/api/reportes/individual/[ID_ESTUDIANTE]
```
**Deberías recibir:** JSON con estructura:
```json
{
  "estudiante": {...},
  "resumen": {...},
  "resultados": [...]
}
```

### Verificar Flutter está correctamente configurado
```dart
// En lib/core/constants/app_constants.dart
static const apiBaseUrl = 'http://localhost:3000/api';
```

---

## 🚨 PROBLEMAS COMUNES

| Problema | Causa | Solución |
|---|---|---|
| Spinner infinito | Backend no corre | `npm start` en terminal 1 |
| "No se encontraron estudiantes" | No existen en BD | Crea en Dashboard → Estudiantes |
| 404 Not Found en DevTools | ID inválido | Obtén ID válido de `/api/estudiantes` |
| 500 Error en DevTools | Bug en backend | Mira terminal del backend, busca el error |
| Datos no se cargan | URL incorrecta | Verifica `apiBaseUrl` en app_constants.dart |

---

## 📋 CHECKLIST ANTES DE TESTEAR

- [ ] Backend `npm start` corriendo sin errores
- [ ] Flutter `flutter run -d chrome` compiló
- [ ] Mínimo 1 estudiante creado en DB
- [ ] Mínimo 1 evaluación completada (para gráficas)
- [ ] `apiBaseUrl = 'http://localhost:3000/api'` verificado

---

## 🎯 META FINAL

Si completas todos los pasos y ves datos reales en la UI desde el backend:

✅ **INTEGRACIÓN EXITOSA**

Ahora puedes:
- Trabajar en otros endpoints
- Mejorar la UI
- Agregar más funcionalidades
- Deployar a producción

---

**¡A testear! 🚀**
