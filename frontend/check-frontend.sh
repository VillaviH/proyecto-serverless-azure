#!/bin/bash

# Script para verificar el estado del frontend
echo "🔍 Verificando Frontend Next.js..."

# Verificar directorio
if [ ! -f "package.json" ]; then
    echo "❌ Error: Debes ejecutar este script desde el directorio frontend/"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo ""

# Verificar configuración
echo "🔧 Configuración:"
echo "- API URL: $(grep NEXT_PUBLIC_API_URL .env.local 2>/dev/null || echo 'No configurada')"
echo ""

# Verificar dependencias
if [ -d "node_modules" ]; then
    echo "✅ Dependencias instaladas"
else
    echo "❌ Dependencias NO instaladas - ejecuta: npm install"
fi

# Verificar si Next.js está corriendo
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend corriendo en http://localhost:3000"
else
    echo "❌ Frontend NO está corriendo"
fi

echo ""

# Mostrar comandos útiles
echo "🛠️ Comandos útiles:"
echo "Iniciar desarrollo: ./start-dev.sh"
echo "Verificar en browser: open http://localhost:3000"
echo "Ver logs: tail -f frontend.log"
echo ""

# Verificar procesos de Node
NODE_PROCESSES=$(ps aux | grep "next" | grep -v grep | wc -l)
if [ $NODE_PROCESSES -gt 0 ]; then
    echo "🔄 Procesos Next.js activos:"
    ps aux | grep "next" | grep -v grep
else
    echo "⚠️ No hay procesos Next.js activos"
fi
