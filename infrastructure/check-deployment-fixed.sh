#!/bin/bash

# Script mejorado para verificar el estado del despliegue
set -e

RESOURCE_GROUP="rg-crud-serverless-villavih"

echo "🔍 Verificando estado del despliegue en $RESOURCE_GROUP..."
echo ""

# Verificar si el grupo de recursos existe
if ! az group exists --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "❌ Error: El grupo de recursos '$RESOURCE_GROUP' no existe."
    echo "   Ejecuta: az group create --name '$RESOURCE_GROUP' --location 'East US'"
    exit 1
fi

echo "✅ Grupo de recursos encontrado: $RESOURCE_GROUP"
echo ""

# Obtener el deployment más reciente
echo "📋 Buscando deployments..."
LATEST_DEPLOYMENT=$(az deployment group list \
    --resource-group "$RESOURCE_GROUP" \
    --query "max_by([], &properties.timestamp).name" \
    --output tsv 2>/dev/null)

if [ -z "$LATEST_DEPLOYMENT" ] || [ "$LATEST_DEPLOYMENT" = "null" ]; then
    echo "⚠️  No se encontraron deployments en el grupo de recursos."
    echo ""
    echo "🚀 Para iniciar el despliegue, ejecuta:"
    echo "az deployment group create \\"
    echo "  --resource-group \"$RESOURCE_GROUP\" \\"
    echo "  --template-file bicep/main.bicep \\"
    echo "  --parameters bicep/main.parameters.json \\"
    echo "  --name \"crud-deployment-\$(date +%Y%m%d-%H%M%S)\""
    exit 1
fi

echo "📋 Deployment más reciente: $LATEST_DEPLOYMENT"

# Verificar estado del deployment
DEPLOYMENT_STATE=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LATEST_DEPLOYMENT" \
    --query "properties.provisioningState" \
    --output tsv)

echo "📊 Estado: $DEPLOYMENT_STATE"
echo ""

case "$DEPLOYMENT_STATE" in
    "Succeeded")
        echo "🎉 ¡DESPLIEGUE COMPLETADO EXITOSAMENTE!"
        echo ""
        echo "📋 Obteniendo información de los recursos creados..."
        
        # Obtener outputs del deployment
        OUTPUTS=$(az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$LATEST_DEPLOYMENT" \
            --query "properties.outputs" \
            --output json)
        
        if [ "$OUTPUTS" != "null" ] && [ -n "$OUTPUTS" ]; then
            FUNCTION_APP_NAME=$(echo "$OUTPUTS" | jq -r '.functionAppName.value // empty')
            FUNCTION_APP_URL=$(echo "$OUTPUTS" | jq -r '.functionAppUrl.value // empty')
            STATIC_WEB_APP_NAME=$(echo "$OUTPUTS" | jq -r '.staticWebAppName.value // empty')
            STATIC_WEB_APP_URL=$(echo "$OUTPUTS" | jq -r '.staticWebAppUrl.value // empty')
            SQL_SERVER_NAME=$(echo "$OUTPUTS" | jq -r '.sqlServerName.value // empty')
            SQL_DATABASE_NAME=$(echo "$OUTPUTS" | jq -r '.sqlDatabaseName.value // empty')
            
            echo "🔗 Recursos creados:"
            echo "   Function App: $FUNCTION_APP_NAME"
            echo "   Function URL: $FUNCTION_APP_URL"
            echo "   Static Web App: $STATIC_WEB_APP_NAME"
            echo "   Static Web URL: $STATIC_WEB_APP_URL"
            echo "   SQL Server: $SQL_SERVER_NAME"
            echo "   SQL Database: $SQL_DATABASE_NAME"
            echo ""
            
            if [ -n "$FUNCTION_APP_NAME" ]; then
                echo "🚀 PRÓXIMOS PASOS:"
                echo ""
                echo "1. Desplegar Backend:"
                echo "   cd ../backend"
                echo "   ./deploy-backend.sh $FUNCTION_APP_NAME"
                echo ""
                
                if [ -n "$STATIC_WEB_APP_NAME" ] && [ -n "$FUNCTION_APP_URL" ]; then
                    echo "2. Desplegar Frontend:"
                    echo "   cd ../frontend"
                    echo "   ./deploy-frontend.sh $STATIC_WEB_APP_NAME $FUNCTION_APP_URL"
                    echo ""
                fi
            fi
        else
            echo "⚠️  No se pudieron obtener los outputs del deployment."
            echo "   Verifica manualmente en Azure Portal."
        fi
        ;;
        
    "Running")
        echo "⏳ DESPLIEGUE EN PROGRESO..."
        echo "   Ejecuta este script nuevamente en unos minutos."
        ;;
        
    "Failed")
        echo "❌ DESPLIEGUE FALLÓ"
        echo ""
        echo "📋 Error:"
        az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$LATEST_DEPLOYMENT" \
            --query "properties.error.message" \
            --output tsv 2>/dev/null || echo "No se pudo obtener el mensaje de error"
        ;;
        
    *)
        echo "❓ Estado desconocido: $DEPLOYMENT_STATE"
        echo "   Verifica manualmente en Azure Portal."
        ;;
esac
