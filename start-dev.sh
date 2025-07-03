#!/bin/bash

# Script maestro para ejecutar backend y frontend localmente
set -e

echo "🚀 Iniciando Aplicación CRUD Serverless en Local"
echo "=============================================="
echo ""

# Función para limpiar procesos al salir
cleanup() {
    echo ""
    echo "🛑 Deteniendo servicios..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        echo "✅ Backend detenido"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
        echo "✅ Frontend detenido"
    fi
    exit 0
}

# Configurar trap para limpiar al salir
trap cleanup SIGINT SIGTERM

# Verificar que estamos en el directorio correcto
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Error: Debes ejecutar este script desde la raíz del proyecto"
    echo "   Estructura esperada: backend/ y frontend/"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo ""

# Verificar dependencias del backend
echo "🔍 Verificando dependencias del backend..."
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK no está instalado"
    echo "   Instalar desde: https://dotnet.microsoft.com/download"
    exit 1
fi

if ! command -v func &> /dev/null; then
    echo "❌ Azure Functions Core Tools no está instalado"
    echo "   Instalar con: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

echo "✅ .NET SDK: $(dotnet --version)"
echo "✅ Azure Functions: $(func --version)"

# Verificar dependencias del frontend
echo ""
echo "🔍 Verificando dependencias del frontend..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    echo "   Instalar desde: https://nodejs.org/"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm no está disponible"
    exit 1
fi

echo "✅ Node.js: $(node --version)"
echo "✅ npm: $(npm --version)"

# Verificar que las dependencias del frontend estén instaladas
if [ ! -d "frontend/node_modules" ]; then
    echo ""
    echo "📦 Instalando dependencias del frontend..."
    cd frontend
    npm install
    cd ..
fi

echo ""
echo "🔧 Compilando backend..."
cd backend
dotnet clean > /dev/null 2>&1
dotnet restore > /dev/null 2>&1
dotnet build --configuration Debug > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación del backend"
    exit 1
fi

cd ..

echo "✅ Backend compilado exitosamente"
echo ""

# Crear logs directory si no existe
mkdir -p logs

echo "🌐 Iniciando servicios..."
echo ""

# Iniciar backend en background
echo "🔧 Iniciando Backend (Azure Functions)..."
cd backend
func start --cors "http://localhost:3000" > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Esperar un poco para que el backend inicie
sleep 3

# Verificar que el backend se inició correctamente
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Error: El backend no se pudo iniciar"
    echo "Ver logs: tail -f logs/backend.log"
    exit 1
fi

echo "✅ Backend iniciado (PID: $BACKEND_PID)"

# Iniciar frontend en background
echo "🌐 Iniciando Frontend (Next.js)..."
cd frontend
npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Esperar un poco para que el frontend inicie
sleep 3

# Verificar que el frontend se inició correctamente
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "❌ Error: El frontend no se pudo iniciar"
    echo "Ver logs: tail -f logs/frontend.log"
    cleanup
    exit 1
fi

echo "✅ Frontend iniciado (PID: $FRONTEND_PID)"
echo ""

# Esperar a que los servicios estén disponibles
echo "⏳ Esperando a que los servicios estén listos..."

# Esperar backend
for i in {1..30}; do
    if curl -s http://localhost:7071 > /dev/null 2>&1; then
        echo "✅ Backend disponible en http://localhost:7071"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo "⚠️ Backend tardando en iniciar, pero continuando..."
    fi
done

# Esperar frontend
for i in {1..30}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo "✅ Frontend disponible en http://localhost:3000"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo "⚠️ Frontend tardando en iniciar, pero continuando..."
    fi
done

echo ""
echo "🎉 ¡Aplicación iniciada exitosamente!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 URLs de la aplicación:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:7071/api"
echo "   API Test:  http://localhost:7071/api/tasks"
echo ""
echo "📋 Endpoints disponibles:"
echo "   GET    /api/tasks           - Obtener todas las tareas"
echo "   POST   /api/tasks           - Crear nueva tarea"
echo "   PUT    /api/tasks/{id}      - Actualizar tarea"
echo "   DELETE /api/tasks/{id}      - Eliminar tarea"
echo ""
echo "📊 Logs en tiempo real:"
echo "   Backend:  tail -f logs/backend.log"
echo "   Frontend: tail -f logs/frontend.log"
echo ""
echo "🧪 Probar la API:"
echo "   curl http://localhost:7071/api/tasks"
echo ""
echo "🌍 Abrir en el navegador:"
echo "   open http://localhost:3000"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🔧 Para detener la aplicación: Ctrl+C"
echo "⏳ Mantén esta terminal abierta mientras desarrollas..."
echo ""

# Mantener el script corriendo y monitorear los procesos
while true; do
    # Verificar que ambos procesos siguen corriendo
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo "❌ Backend se detuvo inesperadamente"
        echo "Ver logs: tail -f logs/backend.log"
        cleanup
        exit 1
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo "❌ Frontend se detuvo inesperadamente"
        echo "Ver logs: tail -f logs/frontend.log"
        cleanup
        exit 1
    fi
    
    sleep 5
done
