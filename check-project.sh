#!/bin/bash

# Script de verificación completa del proyecto
echo "🔍 Verificación Completa del Proyecto CRUD Serverless"
echo "==============================================="
echo ""

# Verificar estructura de directorios
echo "📁 Estructura del Proyecto:"
echo "✅ Frontend: $([ -d "frontend" ] && echo "Presente" || echo "❌ Falta")"
echo "✅ Backend: $([ -d "backend" ] && echo "Presente" || echo "❌ Falta")"
echo "✅ Infrastructure: $([ -d "infrastructure" ] && echo "Presente" || echo "❌ Falta")"
echo ""

# Verificar configuración del frontend
echo "🌐 Frontend Next.js:"
if [ -f "frontend/package.json" ]; then
    echo "✅ package.json presente"
    if [ -d "frontend/node_modules" ]; then
        echo "✅ Dependencias instaladas"
    else
        echo "⚠️ Dependencias no instaladas - ejecutar: cd frontend && npm install"
    fi
    
    if [ -f "frontend/.env.local" ]; then
        echo "✅ Configuración local presente"
        echo "   API URL: $(grep NEXT_PUBLIC_API_URL frontend/.env.local)"
    else
        echo "⚠️ Archivo .env.local no encontrado"
    fi
else
    echo "❌ Frontend no configurado correctamente"
fi

echo ""

# Verificar backend
echo "🔧 Backend .NET:"
if [ -f "backend/TaskApi.csproj" ]; then
    echo "✅ Proyecto .NET presente"
    if [ -f "backend/Program.cs" ]; then
        echo "✅ Program.cs configurado"
    fi
    if [ -f "backend/host.json" ]; then
        echo "✅ host.json presente"
    fi
else
    echo "❌ Backend no configurado correctamente"
fi

echo ""

# Verificar scripts útiles
echo "🛠️ Scripts Disponibles:"
echo "✅ Frontend:"
echo "   - ./frontend/start-dev.sh (iniciar desarrollo)"
echo "   - ./frontend/check-frontend.sh (verificar estado)"
echo ""
echo "✅ Backend:"
echo "   - ./backend/deploy-backend.sh (desplegar a Azure)"
echo "   - ./backend/diagnose-backend.sh (diagnosticar problemas)"
echo ""

# Verificar si hay servicios corriendo
echo "🔄 Servicios Activos:"
NEXT_RUNNING=$(curl -s http://localhost:3000 >/dev/null 2>&1 && echo "✅ Frontend (http://localhost:3000)" || echo "❌ Frontend no está corriendo")
FUNCTIONS_RUNNING=$(curl -s http://localhost:7071 >/dev/null 2>&1 && echo "✅ Backend Local (http://localhost:7071)" || echo "❌ Backend local no está corriendo")

echo "$NEXT_RUNNING"
echo "$FUNCTIONS_RUNNING"

echo ""
echo "🚀 Próximos Pasos Recomendados:"
echo "1. cd frontend && ./start-dev.sh    # Levantar frontend"
echo "2. cd backend && func start         # Levantar backend local (opcional)"
echo "3. open http://localhost:3000       # Verificar frontend"
echo ""
echo "🌩️ Para Azure:"
echo "1. cd backend && ./deploy-backend.sh crudapp-api-prod-ckp33m"
echo "2. cd frontend && ./deploy-frontend.sh crudapp-web-prod-ckp33m https://crudapp-api-prod-ckp33m.azurewebsites.net"
