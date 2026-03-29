# Cambios

## Resumen

Se integraron los avances de `feature/api-connection` y `feature/frontend-base` en una sola rama de trabajo, conectando la aplicacion Flutter con el backend real para autenticacion y gestion de estudiantes.

## Lo que se hizo

- Se conecto el login de Flutter al backend real usando `username`, `password` y `rol`.
- Se elimino el acceso mock que permitia entrar con credenciales falsas cuando fallaba el backend.
- Se creo el repositorio API de estudiantes para listar, buscar, crear, editar y eliminar estudiantes usando el token del docente autenticado.
- Se ajusto el dashboard docente para usar el backend real en lugar del repositorio mock.
- Se mantuvieron e integraron los cambios visuales traidos desde `feature/frontend-base`.
- Se mejoro el manejo de errores para mostrar mensajes del backend en Flutter.
- Se dejo la creacion de estudiantes devolviendo credenciales generadas para login.
- Se ajusto el backend para registrar estudiantes creando tanto el `Usuario` como el documento `Estudiante`.
- Se fijo la carga de variables de entorno del backend desde `backend/.env`.

## Funcionando actualmente en la app

- Login de docente contra backend.
- Login de estudiante contra backend.
- Registro de estudiantes desde el panel docente.
- Persistencia de estudiantes en MongoDB.
- Consulta y busqueda de estudiantes desde el panel docente.
- Edicion y eliminacion de estudiantes desde la interfaz.
- Navegacion base del panel docente y vistas de modulos.
- Interfaz actualizada del frontend base integrada en la rama.

## Notas

- El archivo `backend/.env` se mantuvo fuera de los commits para no subir credenciales sensibles.
- La base de datos correcta definida para trabajar es `Sistema-Educativo`.
