#!/bin/bash

# Script para desplegar la infraestructura CRUD Serverless en Azure
# Asegúrate de tener Azure CLI instalado y estar autenticado

set -e

# Variables
RESOURCE_GROUP_NAME="rg-crud-serverless-villavih"
LOCATION="East US 2"
DEPLOYMENT_NAME="crud-app-deployment-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Iniciando despliegue de aplicación CRUD Serverless..."
echo "📍 Suscripción: $(az account show --query name -o tsv)"
echo "📍 Ubicación: $LOCATION"
echo "📍 Grupo de recursos: $RESOURCE_GROUP_NAME"
echo ""

# Crear grupo de recursos si no existe
echo "📦 Creando grupo de recursos..."
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location "$LOCATION" \
  --output table

echo ""
echo "🏗️  Desplegando infraestructura serverless..."
echo "   - Azure Functions (Backend API)"
echo "   - Azure SQL Database (Serverless)"
echo "   - Azure Static Web Apps (Frontend)"
echo "   - Application Insights (Monitoring)"
echo ""

# Desplegar la infraestructura
az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file main.bicep \
  --parameters main.parameters.json \
  --name $DEPLOYMENT_NAME \
  --output table

# Obtener outputs del despliegue
echo ""
echo "📋 Obteniendo información del despliegue..."

FUNCTION_APP_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs.functionAppName.value \
  --output tsv)

FUNCTION_APP_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs.functionAppUrl.value \
  --output tsv)

STATIC_WEB_APP_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs.staticWebAppName.value \
  --output tsv)

STATIC_WEB_APP_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs.staticWebAppUrl.value \
  --output tsv)

CONNECTION_STRING=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs.connectionString.value \
  --output tsv)

echo ""
echo "✅ ¡Infraestructura desplegada exitosamente!"
echo ""
echo "🌐 URLs de la aplicación:"
echo "   Frontend:  $STATIC_WEB_APP_URL"
echo "   Backend:   $FUNCTION_APP_URL"
echo ""
echo "📝 Información de recursos:"
echo "   Function App: $FUNCTION_APP_NAME"
echo "   Static Web App: $STATIC_WEB_APP_NAME"
echo "   Resource Group: $RESOURCE_GROUP_NAME"
echo ""
echo "🔗 Cadena de conexión SQL (guárdala de forma segura):"
echo "   $CONNECTION_STRING"
echo ""
echo "� Próximos pasos:"
echo "   1. Despliega el código del backend:"
echo "      cd ../backend && func azure functionapp publish $FUNCTION_APP_NAME"
echo ""
echo "   2. Configura el frontend para usar la API de Azure:"
echo "      Actualiza NEXT_PUBLIC_API_URL=$FUNCTION_APP_URL/api"
echo ""
echo "   3. Despliega el frontend usando GitHub o VS Code"
echo ""
echo "🎉 ¡Tu aplicación CRUD serverless está lista!"
