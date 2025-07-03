#!/bin/bash

# Script para ejecutar la aplicación localmente
set -e

echo "🚀 Iniciando aplicación CRUD Serverless..."

# Función para limpiar procesos al salir
cleanup() {
    echo ""
    echo "🛑 Deteniendo servicios..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    echo "✅ Servicios detenidos"
    exit 0
}

# Configurar trap para limpiar al salir
trap cleanup SIGINT SIGTERM

# Verificar que Node.js esté instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instala Node.js 18+"
    exit 1
fi

# Verificar que .NET 8 esté instalado
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET 8 no está instalado. Por favor instala .NET 8 SDK"
    exit 1
fi

# Verificar que Azure Functions Core Tools esté instalado
if ! command -v func &> /dev/null; then
    echo "❌ Azure Functions Core Tools no está instalado."
    echo "   Instala con: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

echo "✅ Prerrequisitos verificados"

# Instalar dependencias del frontend
echo "📦 Instalando dependencias del frontend..."
cd frontend
npm install
cd ..

# Restaurar paquetes del backend
echo "📦 Restaurando paquetes del backend..."
cd backend
dotnet restore
cd ..

# Iniciar el backend (Azure Functions)
echo "🔧 Iniciando backend (Azure Functions)..."
cd backend
func start --port 7071 &
BACKEND_PID=$!
cd ..

# Esperar a que el backend esté listo
echo "⏳ Esperando a que el backend esté listo..."
sleep 10

# Verificar que el backend esté funcionando
if curl -s http://localhost:7071/api/tasks > /dev/null; then
    echo "✅ Backend iniciado correctamente en http://localhost:7071"
else
    echo "❌ Error: El backend no está respondiendo"
    cleanup
    exit 1
fi

# Iniciar el frontend (Next.js)
echo "🎨 Iniciando frontend (Next.js)..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "🎉 Aplicación iniciada exitosamente!"
echo ""
echo "📱 URLs disponibles:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:7071/api"
echo ""
echo "🔗 Endpoints de la API:"
echo "   GET    /api/tasks       - Obtener todas las tareas"
echo "   GET    /api/tasks/{id}  - Obtener una tarea"
echo "   POST   /api/tasks       - Crear nueva tarea"
echo "   PUT    /api/tasks/{id}  - Actualizar tarea"
echo "   DELETE /api/tasks/{id}  - Eliminar tarea"
echo ""
echo "💡 Presiona Ctrl+C para detener todos los servicios"

# Mantener el script corriendo
wait
