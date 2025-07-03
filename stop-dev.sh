#!/bin/bash

# Script para detener todos los servicios de desarrollo
set -e

echo "🛑 Deteniendo servicios de desarrollo..."
echo ""

# Detener procesos en puertos específicos
echo "🔍 Buscando procesos en puertos 3000 y 7071..."

# Detener frontend (puerto 3000)
FRONTEND_PIDS=$(lsof -ti:3000 2>/dev/null || true)
if [ ! -z "$FRONTEND_PIDS" ]; then
    echo "🌐 Deteniendo Frontend (puerto 3000)..."
    echo "$FRONTEND_PIDS" | xargs kill -9 2>/dev/null || true
    echo "✅ Frontend detenido"
else
    echo "ℹ️ No hay procesos en puerto 3000"
fi

# Detener backend (puerto 7071)
BACKEND_PIDS=$(lsof -ti:7071 2>/dev/null || true)
if [ ! -z "$BACKEND_PIDS" ]; then
    echo "🔧 Deteniendo Backend (puerto 7071)..."
    echo "$BACKEND_PIDS" | xargs kill -9 2>/dev/null || true
    echo "✅ Backend detenido"
else
    echo "ℹ️ No hay procesos en puerto 7071"
fi

# Detener procesos de func y npm si están corriendo
echo ""
echo "🔍 Buscando procesos de Node.js y .NET..."

# Detener procesos func (Azure Functions)
FUNC_PIDS=$(ps aux | grep "[f]unc start" | awk '{print $2}' || true)
if [ ! -z "$FUNC_PIDS" ]; then
    echo "🔧 Deteniendo procesos Azure Functions..."
    echo "$FUNC_PIDS" | xargs kill -9 2>/dev/null || true
    echo "✅ Procesos Azure Functions detenidos"
fi

# Detener procesos npm dev
NPM_PIDS=$(ps aux | grep "[n]pm run dev" | awk '{print $2}' || true)
if [ ! -z "$NPM_PIDS" ]; then
    echo "🌐 Deteniendo procesos npm dev..."
    echo "$NPM_PIDS" | xargs kill -9 2>/dev/null || true
    echo "✅ Procesos npm dev detenidos"
fi

# Detener procesos next-server
NEXT_PIDS=$(ps aux | grep "[n]ext-server" | awk '{print $2}' || true)
if [ ! -z "$NEXT_PIDS" ]; then
    echo "🌐 Deteniendo procesos Next.js..."
    echo "$NEXT_PIDS" | xargs kill -9 2>/dev/null || true
    echo "✅ Procesos Next.js detenidos"
fi

echo ""
echo "🧹 Limpiando archivos temporales..."

# Limpiar logs si existen
if [ -d "logs" ]; then
    rm -f logs/backend.log logs/frontend.log
    echo "✅ Logs limpiados"
fi

# Limpiar procesos zombie
echo "🔄 Limpiando procesos zombie..."
wait 2>/dev/null || true

echo ""
echo "✅ ¡Todos los servicios han sido detenidos!"
echo ""
echo "📊 Estado de puertos:"
echo "   Puerto 3000: $(lsof -ti:3000 2>/dev/null && echo "❌ Ocupado" || echo "✅ Libre")"
echo "   Puerto 7071: $(lsof -ti:7071 2>/dev/null && echo "❌ Ocupado" || echo "✅ Libre")"
echo ""
echo "🚀 Para volver a iniciar: ./start-dev.sh"
