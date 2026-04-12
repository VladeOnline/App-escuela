# Cambios Realizados - App Escuela

Fecha: 2026-04-11

## 1) Perfiles con foto (Docente y Estudiante)
- Se habilitó carga de foto desde archivo local (frontend) y envío al backend en formato `data:image/...;base64,...`.
- Se validó tamaño/formato de imagen en backend.
- Se guardó la foto en `Usuario.foto_perfil_url` para que persista en base de datos.
- Se reflejó la foto en vistas de:
  - Topbar / Sidebar de docente.
  - Formularios y tarjetas de estudiantes.
  - Home de estudiante (cuando inicia sesión).

## 2) Estudiantes: creación, edición y sincronización
- `crearEstudiante`:
  - Ahora acepta foto opcional.
  - Responde con `estudiante` serializado + `credenciales` generadas.
- `editarEstudiante`:
  - Actualiza datos académicos y foto.
  - Sincroniza `Usuario.nombre`.
  - Si cambia nombre/edad, también sincroniza credenciales de login:
    - `username = nombre`
    - `password = nombre + edad` (hash en `password_hash`)
  - Evita conflicto de username duplicado.
  - Responde con `estudiante` + `credenciales` actualizadas (cuando aplica).

## 3) Login con datos actualizados
- Se corrigió el problema de no poder entrar con datos editados del estudiante.
- El login ahora funciona con credenciales nuevas tras editar nombre/edad.

## 4) Frontend: contratos y repositorios de estudiantes
- Se extendió el contrato del repositorio para soportar:
  - `photoDataUrl` en create/update.
  - credenciales generadas/actualizadas en respuestas.
- `ApiStudentRepository` actualizado para:
  - enviar foto en create/update,
  - leer respuestas con `estudiante` y `credenciales`.
- `MockStudentRepository` alineado al mismo contrato.

## 5) Mensajes al usuario
- Al crear estudiante: se muestra usuario/contraseña generados.
- Al editar estudiante: si cambian credenciales, se muestran en mensaje de éxito.

## 6) Ajustes visuales y de texto
- Correcciones de textos con caracteres dañados (acentos/símbolos) en varias pantallas.
- Ajustes de render de avatar/foto para fallback correcto cuando no hay imagen.

## 7) Notas operativas
- Error `EADDRINUSE:3000`: se identificó como puerto ocupado por otro proceso del backend.
- Conexión MongoDB:
  - Se revisó error `querySrv ECONNREFUSED` y autenticación.
  - Conexión validada cuando quedó correcto el URI y credenciales.

## Archivos clave tocados (principales)
- `backend/src/controllers/estudianteController.js`
- `backend/src/controllers/authController.js`
- `lib/features/students/presentation/pages/student_form_page.dart`
- `lib/features/students/presentation/pages/student_home_page.dart`
- `lib/features/students/presentation/pages/student_list_page.dart`
- `lib/features/students/presentation/notifiers/students_notifier.dart`
- `lib/features/students/data/repositories/api_student_repository.dart`
- `lib/features/students/data/repositories/mock_student_repository.dart`
- `lib/features/students/domain/repositories/student_repository.dart`
- `lib/features/teacher/presentation/widgets/layout/teacher_sidebar.dart`
- `lib/features/teacher/presentation/pages/teacher_dashboard_page.dart`

## Estado actual
- Flujo de foto y edición de estudiantes funcional.
- Login alineado con credenciales actualizadas.
- Queda recomendado continuar con limpieza de warnings de lint (no bloqueantes).
