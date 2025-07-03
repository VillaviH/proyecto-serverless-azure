#!/bin/bash

# Script para verificar el estado del despliegue y obtener información de los recursos

set -e

RESOURCE_GROUP="rg-crud-serverless-villavih"
DEPLOYMENT_NAME="crud-app-deployment-v2"

echo "🔍 Verificando estado del despliegue..."
echo ""

# Verificar estado del despliegue
DEPLOYMENT_STATE=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --query "properties.provisioningState" \
  --output tsv 2>/dev/null || echo "Not found")

echo "📋 Estado del despliegue: $DEPLOYMENT_STATE"
echo ""

if [ "$DEPLOYMENT_STATE" = "Succeeded" ]; then
    echo "✅ ¡Despliegue completado exitosamente!"
    echo ""
    echo "📋 Información de los recursos creados:"
    echo ""
    
    # Obtener información de los recursos
    FUNCTION_APP_NAME=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.functionAppName.value" \
      --output tsv)
    
    FUNCTION_APP_URL=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.functionAppUrl.value" \
      --output tsv)
    
    STATIC_WEB_APP_NAME=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.staticWebAppName.value" \
      --output tsv)
    
    STATIC_WEB_APP_URL=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.staticWebAppUrl.value" \
      --output tsv)
    
    SQL_SERVER_NAME=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.sqlServerName.value" \
      --output tsv)
    
    SQL_DATABASE_NAME=$(az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.outputs.sqlDatabaseName.value" \
      --output tsv)
    
    echo "🔗 Backend API (Azure Functions):"
    echo "   Nombre: $FUNCTION_APP_NAME"
    echo "   URL: $FUNCTION_APP_URL"
    echo ""
    echo "🌐 Frontend (Static Web App):"
    echo "   Nombre: $STATIC_WEB_APP_NAME"
    echo "   URL: $STATIC_WEB_APP_URL"
    echo ""
    echo "🗄️  Base de Datos (Azure SQL):"
    echo "   Servidor: $SQL_SERVER_NAME"
    echo "   Base de datos: $SQL_DATABASE_NAME"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "1. Ejecutar: cd ../backend && chmod +x deploy-backend.sh && ./deploy-backend.sh $FUNCTION_APP_NAME"
    echo "2. Configurar frontend para producción"
    echo "3. Desplegar frontend a Static Web App"
    echo ""
    
elif [ "$DEPLOYMENT_STATE" = "Running" ]; then
    echo "⏳ Despliegue en progreso..."
    echo "   Ejecuta este script nuevamente en unos minutos para verificar el estado."
    echo ""
    
elif [ "$DEPLOYMENT_STATE" = "Failed" ]; then
    echo "❌ El despliegue falló."
    echo ""
    echo "📋 Detalles del error:"
    az deployment group show \
      --resource-group "$RESOURCE_GROUP" \
      --name "$DEPLOYMENT_NAME" \
      --query "properties.error" \
      --output table
    echo ""
    
else
    echo "❓ Estado desconocido: $DEPLOYMENT_STATE"
    echo "   Verifica manualmente en Azure Portal o con Azure CLI."
    echo ""
fi
