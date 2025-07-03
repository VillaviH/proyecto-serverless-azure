#!/bin/bash

# Script para levantar el frontend en desarrollo
set -e

echo "🚀 Iniciando Frontend Next.js..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: Debes ejecutar este script desde el directorio frontend/"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo "📍 Configuración API: $(grep NEXT_PUBLIC_API_URL .env.local || echo 'No configurada')"
echo ""

# Verificar dependencias
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
else
    echo "✅ Dependencias ya instaladas"
fi

echo ""
echo "🌐 Iniciando servidor de desarrollo..."
echo "📱 Frontend estará disponible en: http://localhost:3000"
echo ""
echo "🔧 Para detener el servidor: Ctrl+C"
echo ""

# Iniciar servidor de desarrollo
npm run dev
