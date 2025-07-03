#!/bin/bash

echo "🔍 Verificando estado de la aplicación..."

# Verificar si el backend está corriendo
if curl -s http://localhost:7071/api/tasks > /dev/null 2>&1; then
    echo "✅ Backend: Running en http://localhost:7071"
    echo "📊 Probando API..."
    curl -s http://localhost:7071/api/tasks | head -c 200
    echo ""
else
    echo "❌ Backend: No está respondiendo en http://localhost:7071"
fi

# Verificar si el frontend está corriendo
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend: Running en http://localhost:3000"
else
    echo "❌ Frontend: No está respondiendo en http://localhost:3000"
fi

echo ""
echo "📱 Para acceder a la aplicación:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:7071/api"
echo ""
echo "🔗 Endpoints disponibles:"
echo "   GET    http://localhost:7071/api/tasks"
echo "   POST   http://localhost:7071/api/tasks"
echo "   PUT    http://localhost:7071/api/tasks/{id}"
echo "   DELETE http://localhost:7071/api/tasks/{id}"
