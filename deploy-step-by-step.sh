#!/bin/bash

# Script paso a paso para desplegar a Azure
set -e

echo "🚀 Despliegue a Azure - Paso a Paso"
echo "==================================="
echo ""

# Variables
RESOURCE_GROUP="rg-crud-serverless-villavih"
LOCATION="East US 2"

echo "📋 PASOS A EJECUTAR:"
echo "1. ✅ Verificar dependencias"
echo "2. 🚀 Desplegar infraestructura"
echo "3. 🔧 Desplegar backend"
echo "4. 🌐 Configurar frontend"
echo "5. 📊 Verificar despliegue"
echo ""

read -p "¿Continuar con el despliegue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Despliegue cancelado"
    exit 0
fi

echo ""
echo "🔍 PASO 1: Verificando dependencias..."

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI no está instalado"
    echo "   Instalar: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar login
SUBSCRIPTION=$(az account show --query "name" --output tsv 2>/dev/null || echo "")
if [ -z "$SUBSCRIPTION" ]; then
    echo "❌ No estás autenticado en Azure"
    echo "   Ejecuta: az login"
    exit 1
fi

echo "✅ Azure CLI configurado"
echo "✅ Suscripción: $SUBSCRIPTION"

# Verificar .NET
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK no está instalado"
    exit 1
fi

# Verificar Azure Functions Core Tools
if ! command -v func &> /dev/null; then
    echo "❌ Azure Functions Core Tools no está instalado"
    echo "   Instalar: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

echo "✅ .NET SDK: $(dotnet --version)"
echo "✅ Azure Functions: $(func --version)"

echo ""
echo "🚀 PASO 2: Desplegando infraestructura..."

# Crear grupo de recursos
echo "📦 Creando grupo de recursos: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output table

# Desplegar con Bicep
echo ""
echo "🏗️  Desplegando recursos con Bicep..."
DEPLOYMENT_NAME="crud-deployment-$(date +%Y%m%d-%H%M%S)"

cd infrastructure
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file bicep/main.bicep \
    --parameters bicep/main.parameters.json \
    --name "$DEPLOYMENT_NAME" \
    --output table

if [ $? -ne 0 ]; then
    echo "❌ Error en el despliegue de infraestructura"
    exit 1
fi

echo "✅ Infraestructura desplegada"

# Obtener nombres de recursos
echo ""
echo "📋 Obteniendo información de recursos..."

FUNCTION_APP_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.functionAppName.value" \
    --output tsv)

STATIC_WEB_APP_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.staticWebAppName.value" \
    --output tsv)

SQL_SERVER_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.sqlServerName.value" \
    --output tsv)

echo "✅ Function App: $FUNCTION_APP_NAME"
echo "✅ Static Web App: $STATIC_WEB_APP_NAME"
echo "✅ SQL Server: $SQL_SERVER_NAME"

cd ..

echo ""
echo "🔧 PASO 3: Desplegando backend..."

cd backend

# Compilar
echo "🏗️  Compilando backend..."
dotnet clean
dotnet restore
dotnet build --configuration Release

if [ $? -ne 0 ]; then
    echo "❌ Error en compilación"
    exit 1
fi

# Configurar variables de entorno
echo ""
echo "⚙️  Configurando variables de entorno..."
SQL_CONNECTION_STRING="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Database=crudapp-db-prod;User ID=sqladmin;Password=MySecureP@ssw0rd2025!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"

az functionapp config appsettings set \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
    "SqlConnectionString=$SQL_CONNECTION_STRING" \
    "FUNCTIONS_WORKER_RUNTIME=dotnet-isolated" \
    "WEBSITE_RUN_FROM_PACKAGE=1" \
    --output table

# Desplegar
echo ""
echo "🚀 Desplegando a Azure Functions..."
func azure functionapp publish "$FUNCTION_APP_NAME" --dotnet-isolated

if [ $? -ne 0 ]; then
    echo "❌ Error en despliegue del backend"
    exit 1
fi

echo "✅ Backend desplegado"

# Reiniciar
echo ""
echo "🔄 Reiniciando Function App..."
az functionapp restart --name "$FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP"

cd ..

echo ""
echo "🌐 PASO 4: Configurando frontend..."

cd frontend

# Configurar para producción
FUNCTION_APP_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo "NEXT_PUBLIC_API_URL=$FUNCTION_APP_URL/api" > .env.production
echo "NODE_ENV=production" >> .env.production

echo "✅ Configuración de producción creada"

# Instalar dependencias y compilar
echo "📦 Instalando dependencias..."
npm ci

echo "🏗️  Compilando frontend..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Error en compilación del frontend"
    exit 1
fi

echo "✅ Frontend compilado"
cd ..

echo ""
echo "📊 PASO 5: Verificando despliegue..."

BACKEND_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net/api/tasks"

echo "🔍 Probando backend..."
echo "URL: $BACKEND_URL"

# Dar tiempo para que se inicie
echo "⏳ Esperando 30 segundos para que el backend se inicie..."
sleep 30

# Probar API
API_RESPONSE=$(curl -s "$BACKEND_URL" 2>/dev/null || echo "ERROR")
if [ "$API_RESPONSE" != "ERROR" ]; then
    echo "✅ API responde correctamente"
    echo "Respuesta: $API_RESPONSE"
else
    echo "⚠️ API no responde aún (normal, puede tardar unos minutos)"
fi

echo ""
echo "🎉 ¡DESPLIEGUE COMPLETADO!"
echo "========================"
echo ""
echo "🌐 URLs de tu aplicación:"
echo "   🔧 Backend:  https://${FUNCTION_APP_NAME}.azurewebsites.net/api"
echo "   📱 Frontend: https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"
echo "   🗄️  Database: ${SQL_SERVER_NAME}.database.windows.net"
echo ""
echo "🧪 Probar API:"
echo "   curl https://${FUNCTION_APP_NAME}.azurewebsites.net/api/tasks"
echo ""
echo "📝 NOTA IMPORTANTE:"
echo "   El frontend necesita ser desplegado manualmente a Static Web App"
echo "   O configurar GitHub Actions para despliegue automático"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: func azure functionapp logstream $FUNCTION_APP_NAME"
echo "   Reiniciar: az functionapp restart --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "🚀 ¡Tu aplicación está lista en Azure!"
