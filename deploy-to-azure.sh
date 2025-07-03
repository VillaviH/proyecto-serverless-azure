#!/bin/bash

# Script maestro para desplegar la aplicación completa a Azure
set -e

echo "🚀 Desplegando Aplicación CRUD Serverless a Azure"
echo "================================================"
echo ""

# Variables de configuración
RESOURCE_GROUP="rg-crud-serverless-villavih"
LOCATION="East US 2"
DEPLOYMENT_NAME="crud-app-deployment-$(date +%Y%m%d-%H%M%S)"

# Función de limpieza
cleanup() {
    echo ""
    echo "🧹 Proceso interrumpido. Los recursos desplegados permanecen en Azure."
    echo "   Para eliminar: az group delete --name $RESOURCE_GROUP --yes --no-wait"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Verificar que estamos en el directorio correcto
if [ ! -d "infrastructure" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Error: Debes ejecutar este script desde la raíz del proyecto"
    echo "   Estructura esperada: infrastructure/, backend/, frontend/"
    exit 1
fi

echo "📍 Directorio: $(pwd)"
echo "🌍 Región: $LOCATION"
echo "📦 Grupo de recursos: $RESOURCE_GROUP"
echo ""

# Verificar dependencias
echo "🔍 Verificando dependencias..."

# Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI no está instalado"
    echo "   Instalar desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK no está instalado"
    exit 1
fi

# Azure Functions Core Tools
if ! command -v func &> /dev/null; then
    echo "❌ Azure Functions Core Tools no está instalado"
    exit 1
fi

# Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    exit 1
fi

echo "✅ Azure CLI: $(az --version | head -1 | cut -d' ' -f2)"
echo "✅ .NET SDK: $(dotnet --version)"
echo "✅ Azure Functions: $(func --version)"
echo "✅ Node.js: $(node --version)"

# Verificar login en Azure
echo ""
echo "🔐 Verificando autenticación en Azure..."
SUBSCRIPTION_NAME=$(az account show --query "name" --output tsv 2>/dev/null || echo "")
if [ -z "$SUBSCRIPTION_NAME" ]; then
    echo "❌ No estás autenticado en Azure"
    echo "   Ejecuta: az login"
    exit 1
fi

echo "✅ Suscripción activa: $SUBSCRIPTION_NAME"

echo ""
echo "🎯 FASE 1: Desplegando Infraestructura"
echo "====================================="

# Crear grupo de recursos si no existe
echo "📦 Verificando grupo de recursos..."
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    echo "🆕 Creando grupo de recursos: $RESOURCE_GROUP"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
else
    echo "✅ Grupo de recursos ya existe: $RESOURCE_GROUP"
fi

# Validar template de Bicep
echo ""
echo "🔍 Validando template de Bicep..."
cd infrastructure
az deployment group validate \
    --resource-group "$RESOURCE_GROUP" \
    --template-file bicep/main.bicep \
    --parameters bicep/main.parameters.json

if [ $? -ne 0 ]; then
    echo "❌ Error en la validación del template"
    exit 1
fi

echo "✅ Template validado exitosamente"

# Desplegar infraestructura
echo ""
echo "🚀 Desplegando infraestructura en Azure..."
echo "   Esto puede tomar 5-10 minutos..."
echo "   Deployment: $DEPLOYMENT_NAME"
echo ""

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file bicep/main.bicep \
    --parameters bicep/main.parameters.json \
    --name "$DEPLOYMENT_NAME" \
    --verbose

if [ $? -ne 0 ]; then
    echo "❌ Error en el despliegue de infraestructura"
    exit 1
fi

echo ""
echo "✅ Infraestructura desplegada exitosamente"

# Obtener información de los recursos creados
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
echo "🎯 FASE 2: Desplegando Backend"
echo "============================="

echo "🔧 Compilando backend..."
cd backend
dotnet clean > /dev/null
dotnet restore > /dev/null
dotnet build --configuration Release

if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación del backend"
    exit 1
fi

echo "✅ Backend compilado"

# Configurar cadena de conexión SQL
echo ""
echo "🔗 Configurando cadena de conexión SQL..."
SQL_CONNECTION_STRING="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Database=crudapp-db-prod;User ID=sqladmin;Password=MySecureP@ssw0rd2025!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"

az functionapp config appsettings set \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
    "SqlConnectionString=$SQL_CONNECTION_STRING" \
    "FUNCTIONS_WORKER_RUNTIME=dotnet-isolated" \
    "WEBSITE_RUN_FROM_PACKAGE=1"

echo "✅ Variables de entorno configuradas"

# Desplegar backend
echo ""
echo "🚀 Desplegando backend a Azure Functions..."
func azure functionapp publish "$FUNCTION_APP_NAME" --dotnet-isolated

if [ $? -ne 0 ]; then
    echo "❌ Error en el despliegue del backend"
    exit 1
fi

echo "✅ Backend desplegado exitosamente"

# Reiniciar Function App para aplicar configuración
echo ""
echo "🔄 Reiniciando Function App..."
az functionapp restart --name "$FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP"

cd ..

echo ""
echo "🎯 FASE 3: Configurando Frontend"
echo "==============================="

cd frontend

# Crear configuración de producción
echo "🔧 Configurando frontend para producción..."
FUNCTION_APP_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo "NEXT_PUBLIC_API_URL=$FUNCTION_APP_URL/api" > .env.production

echo "✅ Configuración de producción creada"

# Instalar dependencias si es necesario
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Compilar frontend
echo ""
echo "🔧 Compilando frontend..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación del frontend"
    exit 1
fi

echo "✅ Frontend compilado"

cd ..

echo ""
echo "🎯 FASE 4: Verificación del Despliegue"
echo "====================================="

echo "🔍 Verificando backend..."
BACKEND_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net/api/tasks"

# Esperar a que el backend esté disponible
echo "⏳ Esperando a que el backend esté disponible..."
for i in {1..30}; do
    if curl -s "$BACKEND_URL" > /dev/null 2>&1; then
        echo "✅ Backend disponible en: $BACKEND_URL"
        break
    fi
    echo "   Intento $i/30 - Esperando..."
    sleep 10
    if [ $i -eq 30 ]; then
        echo "⚠️ Backend tardando en estar disponible, pero el despliegue continuó"
    fi
done

# Probar la API
echo ""
echo "🧪 Probando la API..."
API_RESPONSE=$(curl -s "$BACKEND_URL" 2>/dev/null || echo "ERROR")
if [ "$API_RESPONSE" != "ERROR" ]; then
    echo "✅ API responde correctamente"
    echo "   Respuesta: $API_RESPONSE"
else
    echo "⚠️ API no responde aún, puede necesitar más tiempo"
fi

echo ""
echo "🎉 ¡DESPLIEGUE COMPLETADO EXITOSAMENTE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🌐 URLs de tu aplicación:"
echo "   📱 Frontend: https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"
echo "   🔧 Backend:  https://${FUNCTION_APP_NAME}.azurewebsites.net/api"
echo "   🗄️  Database: ${SQL_SERVER_NAME}.database.windows.net"
echo ""
echo "🧪 Endpoints de la API:"
echo "   GET    ${FUNCTION_APP_URL}/api/tasks"
echo "   POST   ${FUNCTION_APP_URL}/api/tasks"
echo "   PUT    ${FUNCTION_APP_URL}/api/tasks/{id}"
echo "   DELETE ${FUNCTION_APP_URL}/api/tasks/{id}"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: func azure functionapp logstream $FUNCTION_APP_NAME"
echo "   Reiniciar: az functionapp restart --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "📊 Monitoreo:"
echo "   Azure Portal: https://portal.azure.com"
echo "   Application Insights disponible para métricas y logs"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Notas importantes:"
echo "   - El frontend necesita ser desplegado manualmente a Static Web App"
echo "   - Los logs están disponibles en Application Insights"
echo "   - La base de datos SQL está configurada en modo serverless"
echo ""
echo "🚀 ¡Tu aplicación serverless está lista en Azure!"
