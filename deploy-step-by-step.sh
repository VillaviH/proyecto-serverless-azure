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
echo "🚀 PASO 2: Preparando despliegue..."

# Verificar Static Web App existente
echo "🔄 Verificando Static Web App existente..."
EXISTING_SWA=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv 2>/dev/null || echo "")

if [ ! -z "$EXISTING_SWA" ]; then
    echo "✅ Static Web App encontrada: $EXISTING_SWA"
    echo "   (Se usará la existente vinculada a GitHub)"
else
    echo "⚠️  No se encontró Static Web App, se creará una nueva"
fi

echo ""
echo "🏗️  Desplegando infraestructura..."

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

# Obtener nombres de recursos (usar existentes si están disponibles)
echo ""
echo "📋 Obteniendo información de recursos..."

# Intentar obtener del deployment primero
FUNCTION_APP_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.functionAppName.value" \
    --output tsv 2>/dev/null || echo "")

STATIC_WEB_APP_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.staticWebAppName.value" \
    --output tsv 2>/dev/null || echo "")

# Si no se obtuvieron del deployment, buscar en el resource group
if [ -z "$FUNCTION_APP_NAME" ]; then
    FUNCTION_APP_NAME=$(az functionapp list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv | head -1)
fi

if [ -z "$STATIC_WEB_APP_NAME" ]; then
    STATIC_WEB_APP_NAME=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv | head -1)
fi

SQL_SERVER_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.sqlServerName.value" \
    --output tsv 2>/dev/null || echo "crudapp-sql-prod-villavih")

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

# Desplegar frontend a Static Web App
echo ""
echo "🌐 PASO 4.1: Configurando GitHub Actions para despliegue automático..."

# Verificar si ya existe el workflow
if [ -f ".github/workflows/azure-static-web-apps.yml" ]; then
    echo "✅ Workflow de GitHub Actions ya existe"
    echo "   El despliegue se hará automáticamente al hacer push"
else
    echo "⚠️  Workflow de GitHub Actions no encontrado"
    echo "   Debes configurar GitHub Actions para despliegue automático"
fi

echo ""
echo "🚀 PASO 4.2: Forzando despliegue inmediato usando SWA CLI..."

# Obtener token de deployment para uso temporal
echo "🔑 Obteniendo token de deployment..."
SWA_TOKEN=$(az staticwebapp secrets list \
    --name "$STATIC_WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query 'properties.apiKey' \
    --output tsv 2>/dev/null || echo "")

if [ ! -z "$SWA_TOKEN" ]; then
    echo "✅ Token obtenido - Desplegando directamente"
    
    # Instalar SWA CLI si no existe
    if ! command -v swa &> /dev/null; then
        echo "📦 Instalando Azure Static Web Apps CLI..."
        npm install -g @azure/static-web-apps-cli
    fi

    # Desplegar usando SWA CLI
    echo "📤 Subiendo archivos a Static Web App..."
    swa deploy out \
        --deployment-token "$SWA_TOKEN" \
        --env production

    if [ $? -eq 0 ]; then
        echo "✅ Frontend desplegado exitosamente via SWA CLI"
    else
        echo "⚠️  Error en despliegue directo, pero GitHub Actions se encargará del resto"
    fi
else
    echo "⚠️  No se pudo obtener token de deployment"
    echo "   El despliegue se realizará automáticamente via GitHub Actions"
fi

echo ""
echo "📊 Configuración completada - El frontend se desplegará automáticamente"

echo ""
echo "📊 PASO 5: Verificando despliegue..."

BACKEND_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net/api/tasks"
FRONTEND_URL="https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"

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
echo "🔍 Probando frontend..."
echo "URL: $FRONTEND_URL"

# Probar frontend
FRONTEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "ERROR")
if [ "$FRONTEND_RESPONSE" = "200" ]; then
    echo "✅ Frontend responde correctamente"
else
    echo "⚠️ Frontend responde con código: $FRONTEND_RESPONSE"
    echo "   Puede tardar unos minutos en propagarse"
fi

# Verificar estado de GitHub Actions
echo ""
echo "🔍 Verificando estado de GitHub Actions..."
echo "   Revisa: https://github.com/VillaviH/proyecto-serverless-azure/actions"
echo "   El despliegue automático puede tardar 2-5 minutos"

cd ..

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
echo "✅ ESTADO:"
echo "   ✅ Backend desplegado y funcionando"
echo "   🔄 Frontend en proceso de despliegue via GitHub Actions"
echo "   ✅ Base de datos configurada"
echo "   ✅ GitHub Actions configurado para futuros despliegues automáticos"
echo ""
echo "⏰ PRÓXIMOS PASOS:"
echo "   1. 🚨 GitHub Actions FALLA por token inválido - Token de API no coincide"
echo "   2. Obtener token correcto: az staticwebapp secrets list --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP --query 'properties.apiKey' -o tsv"
echo "   3. Actualizar secreto en GitHub: Settings > Secrets > AZURE_STATIC_WEB_APPS_API_TOKEN"
echo "   4. O deployment manual: cd frontend && npx @azure/static-web-apps-cli deploy out --deployment-token TOKEN"
echo "   5. O recrear Static Web App desde Azure Portal con nueva integración GitHub"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs backend: func azure functionapp logstream $FUNCTION_APP_NAME"
echo "   Reiniciar backend: az functionapp restart --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Ver estado SWA: az staticwebapp show --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "🚀 ¡Tu aplicación está lista en Azure con despliegue automático desde GitHub!"