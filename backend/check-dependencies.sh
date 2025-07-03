#!/bin/bash

# Script para verificar las dependencias del backend
echo "🔍 Verificando dependencias del Backend..."
echo ""

# Verificar .NET SDK
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo "✅ .NET SDK: $DOTNET_VERSION"
else
    echo "❌ .NET SDK no está instalado"
    echo "   Instalar desde: https://dotnet.microsoft.com/download"
    echo ""
fi

# Verificar Azure Functions Core Tools
if command -v func &> /dev/null; then
    FUNC_VERSION=$(func --version)
    echo "✅ Azure Functions Core Tools: $FUNC_VERSION"
else
    echo "❌ Azure Functions Core Tools no está instalado"
    echo "   Instalar con: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    echo ""
fi

# Verificar Node.js (necesario para Azure Functions Core Tools)
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js: $NODE_VERSION"
else
    echo "❌ Node.js no está instalado"
    echo "   Instalar desde: https://nodejs.org/"
    echo ""
fi

# Verificar npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm: $NPM_VERSION"
else
    echo "❌ npm no está disponible"
    echo ""
fi

echo ""
echo "📁 Archivos del proyecto:"
if [ -f "TaskApi.csproj" ]; then
    echo "✅ TaskApi.csproj"
else
    echo "❌ TaskApi.csproj no encontrado"
fi

if [ -f "local.settings.json" ]; then
    echo "✅ local.settings.json"
else
    echo "❌ local.settings.json no encontrado"
fi

if [ -f "host.json" ]; then
    echo "✅ host.json"
else
    echo "❌ host.json no encontrado"
fi

echo ""
echo "🚀 Para iniciar el backend local:"
echo "./start-local.sh"
