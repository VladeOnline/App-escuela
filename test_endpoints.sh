#!/bin/bash

# 🧪 SCRIPT DE PRUEBAS RÁPIDAS PARA BACKEND
# Reemplaza BASE_URL y TOKEN con tus valores

BASE_URL="http://localhost:3000"
TOKEN="Tu_token_JWT_aqui"

echo "🟢 PRUEBAS DEL BACKEND - API ESCUELA"
echo "======================================\n"

# 1️⃣ TEST: Login (obtener token)
echo "1️⃣ LOGIN - Obtener Token"
echo "POST $BASE_URL/api/auth/login"
curl -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "docente1",
    "password": "password123",
    "rol": "docente"
  }' | jq .
echo "\n"

# 2️⃣ TEST: Obtener Instrucciones de Evaluación (RF-36, RF-37)
echo "2️⃣ RF-36/37 - Obtener Instrucciones y Tiempo"
echo "GET $BASE_URL/api/reportes/evaluacion/EVALUACION_ID/instrucciones"
echo "(Reemplaza EVALUACION_ID con un ID válido)"
curl -X GET "$BASE_URL/api/reportes/evaluacion/EVALUACION_ID/instrucciones" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo "\n"

# 3️⃣ TEST: Responder Pregunta (RF-24)
echo "3️⃣ RF-24 - Responder Pregunta (retroalimentación inmediata)"
echo "POST $BASE_URL/api/ejercicios/responder"
curl -X POST "$BASE_URL/api/ejercicios/responder" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "estudiante_id": "ESTUDIANTE_ID",
    "evaluacion_id": "EVALUACION_ID",
    "ejercicio_id": "EJERCICIO_ID",
    "respuesta_dada": "respuesta"
  }' | jq .
echo "\n"

# 4️⃣ TEST: Obtener Historial de Evaluaciones (RF-41)
echo "4️⃣ RF-41 - Obtener Historial de Evaluaciones"
echo "GET $BASE_URL/api/reportes/historial/ESTUDIANTE_ID"
curl -X GET "$BASE_URL/api/reportes/historial/ESTUDIANTE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo "\n"

# 5️⃣ TEST: Reiniciar Puntuaciones (RF-44)
echo "5️⃣ RF-44 - Reiniciar Puntuaciones"
echo "POST $BASE_URL/api/reportes/admin/reiniciar/ESTUDIANTE_ID"
curl -X POST "$BASE_URL/api/reportes/admin/reiniciar/ESTUDIANTE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tipo_reinicio": "completo"
  }' | jq .
echo "\n"

# 6️⃣ TEST: Crear Ejercicio (RF-26 registra en log)
echo "6️⃣ RF-26 - Crear Ejercicio (registra en log)"
echo "POST $BASE_URL/api/ejercicios/"
curl -X POST "$BASE_URL/api/ejercicios/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contenido_id": "CONTENIDO_ID",
    "evaluacion_id": "EVALUACION_ID",
    "pregunta": "¿Cuál es la capital de España?",
    "opciones": ["Madrid", "Barcelona", "Valencia"],
    "respuesta_correcta": "Madrid",
    "dificultad": "facil"
  }' | jq .
echo "\n"

# 7️⃣ TEST: Obtener Reporte Individual (RF-17)
echo "7️⃣ Obtener Reporte Individual"
echo "GET $BASE_URL/api/reportes/individual/ESTUDIANTE_ID"
curl -X GET "$BASE_URL/api/reportes/individual/ESTUDIANTE_ID" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo "\n"

echo "✅ PRUEBAS COMPLETADAS"
echo "======================================="
echo ""
echo "📝 NOTAS:"
echo "  - Reemplaza ESTUDIANTE_ID, EVALUACION_ID, EJERCICIO_ID con valores válidos"
echo "  - El TOKEN debe ser válido (obtenido de login)"
echo "  - Necesitas tener jq instalado para formatear JSON"
echo "  - Si no tienes jq, elimina ' | jq .' del final de cada curl"
