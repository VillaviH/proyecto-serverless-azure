#!/bin/bash

# Script para verificar el estado de los servicios de desarrollo
echo "🔍 Estado de los Servicios de Desarrollo"
echo "========================================"
echo ""

# Verificar puertos
echo "📊 Estado de Puertos:"
FRONTEND_PORT=$(lsof -ti:3000 2>/dev/null && echo "🟢 ACTIVO" || echo "🔴 LIBRE")
BACKEND_PORT=$(lsof -ti:7071 2>/dev/null && echo "🟢 ACTIVO" || echo "🔴 LIBRE")

echo "   Frontend (3000): $FRONTEND_PORT"
echo "   Backend (7071):  $BACKEND_PORT"
echo ""

# Verificar conectividad
echo "🌐 Conectividad:"
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "   Frontend: ✅ Responde en http://localhost:3000"
else
    echo "   Frontend: ❌ No responde"
fi

if curl -s http://localhost:7071 > /dev/null 2>&1; then
    echo "   Backend:  ✅ Responde en http://localhost:7071"
else
    echo "   Backend:  ❌ No responde"
fi

# Probar API
echo ""
echo "🧪 Prueba de API:"
API_RESPONSE=$(curl -s http://localhost:7071/api/tasks 2>/dev/null || echo "ERROR")
if [ "$API_RESPONSE" != "ERROR" ]; then
    echo "   GET /api/tasks: ✅ Responde"
    echo "   Respuesta: $API_RESPONSE"
else
    echo "   GET /api/tasks: ❌ No responde"
fi

echo ""

# Mostrar procesos relacionados
echo "🔄 Procesos Activos:"
FUNC_PROCESSES=$(ps aux | grep "[f]unc start" | wc -l)
NPM_PROCESSES=$(ps aux | grep "[n]pm run dev" | wc -l)
NEXT_PROCESSES=$(ps aux | grep "[n]ext-server" | wc -l)

echo "   Azure Functions: $FUNC_PROCESSES procesos"
echo "   npm run dev:     $NPM_PROCESSES procesos"
echo "   Next.js server:  $NEXT_PROCESSES procesos"

echo ""

# Mostrar logs recientes si existen
if [ -f "logs/backend.log" ]; then
    echo "📋 Últimas líneas del Backend:"
    tail -3 logs/backend.log 2>/dev/null || echo "   No hay logs disponibles"
    echo ""
fi

if [ -f "logs/frontend.log" ]; then
    echo "📋 Últimas líneas del Frontend:"
    tail -3 logs/frontend.log 2>/dev/null || echo "   No hay logs disponibles"
    echo ""
fi

# Comandos útiles
echo "🛠️ Comandos Útiles:"
echo "   Iniciar todo:    ./start-dev.sh"
echo "   Detener todo:    ./stop-dev.sh"
echo "   Ver logs backend: tail -f logs/backend.log"
echo "   Ver logs frontend: tail -f logs/frontend.log"
echo "   Abrir frontend:  open http://localhost:3000"
echo "   Probar API:      curl http://localhost:7071/api/tasks"
