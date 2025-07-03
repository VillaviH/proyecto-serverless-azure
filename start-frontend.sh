#!/bin/bash

echo "🚀 Iniciando Frontend (Next.js)..."

# Navegar al directorio del frontend
cd "$(dirname "$0")/frontend"

# Verificar si Node.js está disponible
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    exit 1
fi

# Verificar si las dependencias están instaladas
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Matar cualquier proceso en el puerto 3000
echo "🧹 Limpiando puerto 3000..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

# Esperar un momento
sleep 2

# Iniciar el frontend
echo "▶️  Iniciando Next.js en http://localhost:3000"
npm run dev

echo "✅ Frontend iniciado exitosamente"
