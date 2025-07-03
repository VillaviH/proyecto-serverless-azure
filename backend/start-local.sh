#!/bin/bash

# Script para levantar el backend Azure Functions localmente
set -e

echo "🚀 Iniciando Backend Azure Functions (.NET 8)..."

# Verificar que estamos en el directorio correcto
if [ ! -f "TaskApi.csproj" ]; then
    echo "❌ Error: Debes ejecutar este script desde el directorio backend/"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo ""

# Verificar dependencias necesarias
echo "🔍 Verificando dependencias..."

# Verificar .NET 8
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo "✅ .NET SDK: $DOTNET_VERSION"
else
    echo "❌ .NET SDK no está instalado"
    echo "   Instalar desde: https://dotnet.microsoft.com/download"
    exit 1
fi

# Verificar Azure Functions Core Tools
if command -v func &> /dev/null; then
    FUNC_VERSION=$(func --version)
    echo "✅ Azure Functions Core Tools: $FUNC_VERSION"
else
    echo "❌ Azure Functions Core Tools no está instalado"
    echo "   Instalar con: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

echo ""

# Verificar configuración
echo "🔧 Configuración actual:"
echo "- Runtime: $(grep FUNCTIONS_WORKER_RUNTIME local.settings.json | cut -d'"' -f4)"
echo "- DB: $(grep SqlConnectionString local.settings.json | cut -d'"' -f4)"
echo ""

# Limpiar compilaciones anteriores
echo "🧹 Limpiando compilación anterior..."
dotnet clean > /dev/null

# Restaurar paquetes
echo "📦 Restaurando paquetes NuGet..."
dotnet restore

# Compilar proyecto
echo "🔨 Compilando proyecto..."
dotnet build --configuration Debug

if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación. Revisa los errores arriba."
    exit 1
fi

echo ""
echo "✅ Compilación exitosa!"
echo ""

# Configurar CORS para desarrollo local
echo "🔧 Configurando CORS para desarrollo local..."

# Crear configuración temporal si no existe
if [ ! -f "cors.json" ]; then
    cat > cors.json << EOF
{
  "cors": {
    "credentials": false,
    "methods": [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "OPTIONS"
    ],
    "origins": [
      "http://localhost:3000",
      "http://127.0.0.1:3000"
    ]
  }
}
EOF
fi

echo ""
echo "🌐 Iniciando Azure Functions Host..."
echo "📡 Backend estará disponible en: http://localhost:7071"
echo "🔗 API Base URL: http://localhost:7071/api"
echo ""
echo "📋 Endpoints disponibles:"
echo "  GET    /api/tasks           - Obtener todas las tareas"
echo "  GET    /api/tasks/{id}      - Obtener tarea por ID"
echo "  POST   /api/tasks           - Crear nueva tarea"
echo "  PUT    /api/tasks/{id}      - Actualizar tarea"
echo "  DELETE /api/tasks/{id}      - Eliminar tarea"
echo ""
echo "🔧 Para detener el servidor: Ctrl+C"
echo "🔍 Para ver logs detallados: func start --verbose"
echo ""

# Iniciar Azure Functions
func start --cors "http://localhost:3000,http://127.0.0.1:3000"
