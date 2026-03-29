## 🗂️ Estructura del proyecto (Front)

```
lib/
├── core/
│   ├── constants/       → app_constants.dart, app_routes.dart
│   ├── errors/          → app_failure.dart
│   └── theme/           → app_theme.dart
├── features/
│   ├── auth/            → login, selección de rol, AuthNotifier
│   ├── modules/         → módulos de lectura/escritura, ejercicios
│   ├── students/        → CRUD de estudiantes, condiciones especiales
│   └── teacher/         → dashboard, sidebar, topbar, modales
└── shared/widgets/      → snackbar, confirm_dialog, grade_badge
```

---

## 🔌 Conexiones requeridas por área

### 1. Autenticación

**Archivo:** `lib/features/auth/presentation/auth_notifier.dart`  
**Archivo:** `lib/services/auth_service.dart`

- [ ] Conectar el login real con el endpoint de autenticación
- [ ] El `AuthNotifier` ya maneja el estado de sesión — alimentarlo con la respuesta del login (nombre del docente, rol, token, etc.)
- [ ] Implementar `AuthService.changePassword(currentPassword, newPassword)` — el modal ya existe en `change_password_modal.dart`
- [ ] Conectar el logout con invalidación de token en el servidor

```dart
// En auth_notifier.dart buscar:
// TODO(back): conectar con el endpoint real de login
```

---

### 2. Datos del docente (nombre, foto de perfil)

**Archivos con TODO(back):**
- `lib/features/teacher/presentation/pages/teacher_dashboard_page.dart`
- `lib/features/teacher/presentation/widgets/layout/teacher_sidebar.dart`
- `lib/features/teacher/presentation/widgets/layout/teacher_topbar.dart`

- [ ] El nombre del docente (`teacherName`) actualmente está hardcodeado como `'Juan'` — reemplazar con `AuthNotifier.state.userName` (o el campo que devuelva el endpoint de login)
- [ ] La foto de perfil usa `assets/images/buho_profesor.png` como default en sidebar y topbar — cuando el docente tenga foto guardada, reemplazar con `Image.network(teacher.photoUrl)`
- [ ] **Si el docente no tiene foto asignada, debe quedarse el búho por defecto** — el Front ya maneja ese fallback con `errorBuilder`
- [ ] El saludo dinámico (buenos días/tardes/noches) ya funciona con `DateTime.now()` — no requiere cambios

```dart
// En teacher_dashboard_page.dart buscar:
// TODO(back): obtener nombre real desde AuthNotifier.state
```

---

### 3. Dashboard — estadísticas reales

**Archivo:** `lib/features/teacher/presentation/widgets/dashboard/stats_overview_row.dart`  
**Archivo:** `lib/features/teacher/domain/models/dashboard_stat.dart`

Actualmente el dashboard muestra datos mock:
- `8 Estudiantes este año`
- `2 Casos graves`
- `10 Sesiones recientes`
- `70% Progreso promedio`

- [ ] Crear endpoint que devuelva estas 4 estadísticas por docente
- [ ] Reemplazar `StatsOverviewRow.mock()` en `teacher_dashboard_page.dart` con datos reales del endpoint
- [ ] El `DashboardStat` tiene: `label`, `value` (String), `sublabel`, `icon`, `color` — el Back solo necesita proveer `label`, `value` y `sublabel`; los colores e íconos los maneja el Front

---

### 4. Estudiantes

**Archivos:**
- `lib/features/students/domain/repositories/student_repository.dart` → **interfaz/contrato**
- `lib/features/students/data/repositories/mock_student_repository.dart` → **reemplazar con implementación real**
- `lib/features/students/domain/entities/student_entity.dart` → **entidad**

La entidad `StudentEntity` tiene los siguientes campos:

```dart
String id
String fullName
int grade           // 1–6
int age
bool isActive
DateTime createdAt
List<String> conditions   // condiciones especiales: ['TEA', 'TDAH', etc.]
```

- [ ] Implementar los 5 métodos del contrato `StudentRepository`: `getAll()`, `search()`, `create()`, `update()`, `delete()`
- [ ] Los estudiantes deben llegar **con todos los campos**, incluyendo `conditions`
- [ ] **Foto de perfil del estudiante:** agregar campo `photoUrl` a la entidad y al endpoint. El Front ya tiene el `TODO(back)` en las cards de estudiantes para mostrar `Image.network(student.photoUrl)` cuando exista; si no hay foto, se muestran las iniciales del nombre automáticamente
- [ ] Eliminar los datos hardcodeados del `mock_student_repository.dart` una vez conectada la BD

```dart
// En student_form_page.dart buscar:
// TODO(back): conectar con file_picker para subir foto del estudiante

// En teacher_dashboard_page.dart y student_list_page.dart buscar:
// TODO(back): reemplazar StudentAvatar con Image.network(student.photoUrl)
```

---

### 5. Condiciones especiales de estudiantes

**Archivo:** `lib/features/students/domain/entities/student_entity.dart`

El campo `conditions` ya está implementado en el Front como `List<String>`.  
Las condiciones disponibles actualmente son:

| Código | Descripción |
|--------|-------------|
| `TEA` | Trastorno del Espectro Autista |
| `TDAH` | Trastorno por Déficit de Atención |
| `Dislexia` | Dificultad en lectoescritura |
| `Discalculia` | Dificultad con números |
| `Hipoacusia` | Pérdida parcial de audición |
| `Baja visión` | Dificultad visual parcial |

- [ ] Guardar y devolver el array `conditions` en la BD junto con cada estudiante
- [ ] El botón "Más condiciones conocidas" en el formulario está reservado para una futura expansión — conectar cuando se defina el listado completo

```dart
// En student_form_page.dart buscar:
// TODO(back/future): abrir panel lateral con más condiciones disponibles
```

---

### 6. Módulos y ejercicios

**Archivos:**
- `lib/features/modules/data/repositories/mock_module_repository.dart` → **reemplazar**
- `lib/features/modules/domain/entities/module_entities.dart` → **entidades**

Las entidades de módulos son:

```dart
ModuleEntity     → id, title, description, grade, type (reading/writing), exercises
ExerciseEntity   → id, title, description, type, difficulty, content, options, correctAnswer
ExerciseResult   → studentId, exerciseId, score, isCorrect, answeredAt
```

- [ ] **El Front no debe trabajar los módulos hasta que el Back haya conectado los endpoints** — actualmente usan datos mock
- [ ] Implementar endpoints para: listar módulos por tipo y grado, obtener ejercicios de un módulo, registrar resultado de ejercicio
- [ ] Los tipos de ejercicio son: `multipleChoice`, `fillInTheBlank`, `trueOrFalse`, `ordering` (ordering está pendiente de implementación Front)
- [ ] Los niveles de dificultad y sus puntos: `basic = 10pts`, `intermediate = 20pts`, `advanced = 30pts`

---

### 7. Cambio de contraseña

**Archivo:** `lib/features/teacher/presentation/widgets/modals/change_password_modal.dart`

- [ ] Implementar `AuthService.changePassword(currentPassword, newPassword)`
- [ ] El modal ya valida localmente (mínimo 6 caracteres, que coincidan) y muestra loading/error
- [ ] Después de cambiar contraseña, el docente debe cerrar sesión en todos los dispositivos

```dart
// En change_password_modal.dart buscar:
// TODO(back): AuthService.changePassword(_currentCtrl.text, _newCtrl.text)
```

---

### 8. Video tutorial (modal de ayuda)

**Archivo:** `lib/features/teacher/presentation/widgets/modals/help_modal.dart`

- [ ] Reemplazar la URL vacía `_videoUrl = ''` con la URL real del video tutorial cuando esté disponible

---

## 🔍 Búsqueda rápida de TODOs

Para encontrar todos los puntos de integración en el código:

```bash
grep -rn "TODO(back)" lib/
```

---

## ⚠️ Notas importantes

1. **No modificar archivos de UI** — todos los cambios de Back deben limitarse a los repositorios (`data/repositories/`) y servicios (`services/`)
2. **El contrato del repositorio de estudiantes** está en `domain/repositories/student_repository.dart` — la implementación real debe respetar exactamente esa interfaz
3. **Los datos mock se eliminan solos** al reemplazar `MockStudentRepository` y `MockModuleRepository` con las implementaciones reales — no hay que tocar el resto del código
4. **Las rutas de navegación** están centralizadas en `core/constants/app_routes.dart`
5. **El manejo de errores** ya está implementado con `AppFailure` — el Back solo necesita devolver los mensajes de error apropiados

---
