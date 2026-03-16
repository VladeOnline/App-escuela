# 🏫 Refuerzo Escolar — Guía de Integración Back-End

> **Para el equipo de Back-End:** Este documento explica qué hizo el equipo de Front-End en el Sprint 1, qué archivos les corresponde modificar y cómo conectar sus servicios sin romper nada.

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart   ← constantes globales (roles, API URL, claves)
│   │   └── app_routes.dart      ← rutas de navegación
│   ├── errors/
│   │   └── app_failure.dart     ← tipos de error del dominio
│   └── theme/                   ← diseño visual (no tocar)
├── features/
│   ├── auth/
│   │   ├── auth_notifier.dart           ← ⭐ PUNTO DE INTEGRACIÓN AUTH
│   │   └── presentation/pages/
│   │       ├── login_page.dart
│   │       ├── teacher_home_page.dart
│   │       └── student_home_page.dart
│   └── students/
│       ├── domain/
│       │   ├── entities/student_entity.dart         ← modelo de datos
│       │   ├── repositories/student_repository.dart ← ⭐ CONTRATO A IMPLEMENTAR
│       │   └── usecases/validate_student_usecase.dart
│       ├── data/
│       │   └── repositories/mock_student_repository.dart ← ⭐ REEMPLAZAR CON MONGODB
│       └── presentation/          ← UI (no tocar)
└── shared/widgets/                ← componentes reutilizables (no tocar)
```

---

## ⭐ Archivos que el Back-End debe modificar

### 1. `lib/core/constants/app_constants.dart`
**Cambiar la URL de la API:**
```dart
// ❌ Actual (mock local)
static const apiBaseUrl = 'http://10.0.2.2:3000/api';

// ✅ Cambiar por la URL real cuando esté desplegado
static const apiBaseUrl = 'https://su-servidor.com/api';
```

**Las claves de almacenamiento ya están definidas** — úsenlas tal cual:
```dart
static const tokenKey = 'auth_token';  // clave para guardar el JWT
static const roleKey  = 'user_role';   // clave para guardar el rol
```

---

### 2. `lib/features/auth/auth_notifier.dart`
**Este es el archivo principal de autenticación.**

Actualmente usa una validación mock. Para conectar el Back-End real:

```dart
// ❌ Actual — validación local mock
Future<bool> login({required String password, required String role}) async {
  await Future.delayed(const Duration(milliseconds: 600)); // simulación
  final isValid = _mockValidate(password: password, role: role);
  ...
}

// ✅ Reemplazar por — llamada real al API
Future<bool> login({required String password, required String role}) async {
  _emit(_state.copyWith(status: AuthStatus.loading));
  try {
    // Reemplazar esta línea con su servicio real:
    final response = await AuthService.login(password: password, role: role);
    setAuth(response.token, response.role);
    return true;
  } catch (e) {
    _emit(_state.copyWith(
      status: AuthStatus.failure,
      failure: AuthFailure(e.toString()),
    ));
    return false;
  }
}
```

El método `setAuth(token, role)` **ya existe** y acepta el JWT real:
```dart
// Llamar esto cuando tengan el token del servidor:
authNotifier.setAuth('jwt_token_real', 'docente');
```

---

### 3. `lib/features/students/data/repositories/mock_student_repository.dart`
**Este archivo es el que más les corresponde al Back-End.**

Actualmente guarda los datos en memoria local (mock). Para conectar MongoDB:

**Paso 1:** Crear un nuevo archivo:
```
lib/features/students/data/repositories/mongo_student_repository.dart
```

**Paso 2:** Implementar la misma interfaz:
```dart
import '../../domain/repositories/student_repository.dart';

class MongoStudentRepository implements StudentRepository {
  // Implementar todos los métodos del contrato:
  // getAll(), search(), create(), update(), delete(), deactivate()
  
  @override
  Future<({List<StudentEntity> students, AppFailure? failure})> getAll() async {
    // Su lógica con MongoDB aquí
  }
  
  // ... resto de métodos
}
```

**Paso 3:** En `lib/features/auth/presentation/pages/teacher_home_page.dart`,
cambiar una sola línea:
```dart
// ❌ Actual
late final StudentsNotifier _studentsNotifier = StudentsNotifier(
  repository: MockStudentRepository(), // 👈 esta línea
  validator: const ValidateStudentUseCase(),
);

// ✅ Reemplazar por
late final StudentsNotifier _studentsNotifier = StudentsNotifier(
  repository: MongoStudentRepository(), // 👈 solo cambiar esto
  validator: const ValidateStudentUseCase(),
);
```

> **Importante:** El contrato `StudentRepository` **no cambia**. El Front-End no necesita saber si los datos vienen de MongoDB, de una API REST o de otro origen — solo consume la interfaz.

---

## 📋 Contrato del Repositorio de Estudiantes

Estos son todos los métodos que deben implementar en `MongoStudentRepository`:

| Método | Descripción | RF |
|--------|-------------|-----|
| `getAll()` | Retorna todos los estudiantes activos | RF-01 |
| `search({name, grade})` | Busca por nombre o grado | RF-31 |
| `create({fullName, grade, age})` | Registra un nuevo estudiante | RF-01 |
| `update({id, fullName, grade, age})` | Edita un estudiante | RF-02 |
| `delete(id)` | Elimina un estudiante | RF-03 |
| `deactivate(id)` | Desactiva sin eliminar | RF-42 |

Todos retornan un **record de Dart** con el resultado y un posible error:
```dart
// Ejemplo de retorno exitoso:
return (students: listaDeEstudiantes, failure: null);

// Ejemplo de retorno con error:
return (students: [], failure: NotFoundFailure('No se encontraron estudiantes'));
```

---

## 🔐 Tipos de Error Disponibles

Definidos en `lib/core/errors/app_failure.dart`:

```dart
ValidationFailure('mensaje')   // datos inválidos
NotFoundFailure('mensaje')     // recurso no encontrado
DuplicateFailure('mensaje')    // registro duplicado
AuthFailure('mensaje')         // error de autenticación
UnexpectedFailure('mensaje')   // error inesperado del servidor
```

---

## 🚀 Resumen de RFs implementados en Sprint 1

| RF | Descripción | Estado |
|----|-------------|--------|
| RF-01 | Registrar estudiantes con nombre, grado y edad | ✅ UI lista |
| RF-02 | Editar información de estudiantes | ✅ UI lista |
| RF-03 | Eliminar estudiantes | ✅ UI lista |
| RF-04 | Asignar estudiante a un único grado | ✅ UI lista |
| RF-05 | Autenticación por roles (docente/estudiante) | ✅ Mock — conectar API |
| RF-06 | Cierre de sesión seguro | ✅ Funcional |
| RF-31 | Buscar estudiantes por nombre o grado | ✅ UI lista |

---
