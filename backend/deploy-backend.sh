#!/bin/bash

# Script para desplegar el backend a Azure Functions
set -e

echo "🔧 Desplegando Backend (.NET Core 8 + Azure Functions)..."

# Variables (estas serán proporcionadas por el script de infraestructura)
FUNCTION_APP_NAME="$1"
RESOURCE_GROUP_NAME="rg-crud-serverless-villavih"

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo "❌ Error: Se requiere el nombre de la Function App"
    echo "Uso: ./deploy-backend.sh <FUNCTION_APP_NAME>"
    echo "Ejemplo: ./deploy-backend.sh crud-demo-villavih-api-prod-abc123"
    exit 1
fi

echo "📍 Function App: $FUNCTION_APP_NAME"
echo "📍 Resource Group: $RESOURCE_GROUP_NAME"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "TaskApi.csproj" ]; then
    echo "❌ Error: Debes ejecutar este script desde el directorio backend/"
    exit 1
fi

# Limpiar compilación anterior
echo "🧹 Limpiando compilación anterior..."
dotnet clean

# Restaurar paquetes
echo "📦 Restaurando paquetes NuGet..."
dotnet restore

# Compilar proyecto
echo "🔨 Compilando proyecto..."
dotnet build --configuration Release

# Verificar que no hay errores de compilación
if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación. Revisa los errores arriba."
    exit 1
fi

# Configurar las variables de entorno necesarias antes del despliegue
echo "🔧 Configurando variables de entorno en Function App..."
az functionapp config appsettings set \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --settings \
    "FUNCTIONS_WORKER_RUNTIME=dotnet-isolated" \
    "WEBSITE_RUN_FROM_PACKAGE=1" \
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE=true"

# Desplegar a Azure Functions
echo "🚀 Desplegando a Azure Functions..."
func azure functionapp publish $FUNCTION_APP_NAME --dotnet-isolated

echo ""
echo "✅ ¡Backend desplegado exitosamente!"
echo ""
echo "🌐 URL del API: https://$FUNCTION_APP_NAME.azurewebsites.net/api"
echo ""
echo "� Reiniciando Function App para aplicar cambios..."
az functionapp restart --name "$FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME"

echo ""
echo "�🔍 Para verificar el despliegue:"
echo "   curl https://$FUNCTION_APP_NAME.azurewebsites.net/api/tasks"
echo ""
echo "📊 Para ver logs en tiempo real:"
echo "   func azure functionapp logstream $FUNCTION_APP_NAME"
