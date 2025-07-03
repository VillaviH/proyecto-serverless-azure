#!/bin/bash

# Script simplificado para verificar el último deployment

RESOURCE_GROUP="rg-crud-serverless-villavih"

echo "🔍 Verificando último deployment en Azure..."
echo "📍 Grupo de recursos: $RESOURCE_GROUP"
echo ""

# Verificar si el grupo de recursos existe
GROUP_EXISTS=$(az group exists --name "$RESOURCE_GROUP" 2>/dev/null || echo "false")

if [ "$GROUP_EXISTS" = "true" ]; then
    echo "✅ Grupo de recursos existe"
    
    # Obtener el último deployment
    LATEST_DEPLOYMENT=$(az deployment group list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[0].name" \
        --output tsv 2>/dev/null)
    
    if [ -n "$LATEST_DEPLOYMENT" ] && [ "$LATEST_DEPLOYMENT" != "null" ]; then
        echo "📋 Último deployment: $LATEST_DEPLOYMENT"
        
        # Obtener estado
        STATE=$(az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$LATEST_DEPLOYMENT" \
            --query "properties.provisioningState" \
            --output tsv 2>/dev/null)
        
        echo "📊 Estado: $STATE"
        
        if [ "$STATE" = "Succeeded" ]; then
            echo ""
            echo "🎉 ¡DEPLOYMENT EXITOSO!"
            echo ""
            
            # Obtener outputs
            echo "📋 Recursos creados:"
            
            FUNCTION_APP=$(az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$LATEST_DEPLOYMENT" \
                --query "properties.outputs.functionAppName.value" \
                --output tsv 2>/dev/null)
            
            FUNCTION_URL=$(az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$LATEST_DEPLOYMENT" \
                --query "properties.outputs.functionAppUrl.value" \
                --output tsv 2>/dev/null)
            
            WEBAPP_NAME=$(az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$LATEST_DEPLOYMENT" \
                --query "properties.outputs.staticWebAppName.value" \
                --output tsv 2>/dev/null)
            
            echo "🔗 Function App: $FUNCTION_APP"
            echo "🔗 Function URL: $FUNCTION_URL"
            echo "🔗 Static Web App: $WEBAPP_NAME"
            echo ""
            echo "🚀 PRÓXIMOS PASOS:"
            echo "1. cd ../backend"
            echo "2. ./deploy-backend.sh $FUNCTION_APP"
            echo "3. cd ../frontend"
            echo "4. ./deploy-frontend.sh $WEBAPP_NAME $FUNCTION_URL"
            
        elif [ "$STATE" = "Failed" ]; then
            echo "❌ Deployment falló"
            az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$LATEST_DEPLOYMENT" \
                --query "properties.error" 2>/dev/null
                
        else
            echo "⏳ Deployment en progreso: $STATE"
        fi
        
    else
        echo "⚠️ No se encontraron deployments"
    fi
    
else
    echo "❌ Grupo de recursos no existe"
fi
