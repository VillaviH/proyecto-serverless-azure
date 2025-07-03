#!/becho "🔍 Monitoreando deployment 'crud-app-deployment-v3'..."n/bash

# Script simple para monitorear el deployment actual

echo "🔍 Monitoreando deployment 'crud-app-deployment-v2'..."
echo ""

while true; do
    echo "$(date '+%H:%M:%S') - Verificando estado..."
    
    STATE=$(az deployment group show \
        --resource-group "rg-crud-serverless-villavih" \
        --name "crud-app-deployment-v2" \
        --query "properties.provisioningState" \
        --output tsv 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "📊 Estado: $STATE"
        
        if [ "$STATE" = "Succeeded" ]; then
            echo ""
            echo "🎉 ¡DEPLOYMENT EXITOSO!"
            echo ""
            echo "📋 Obteniendo información de recursos..."
            
            FUNCTION_APP=$(az deployment group show \
                --resource-group "rg-crud-serverless-villavih" \
                --name "crud-app-deployment-v2" \
                --query "properties.outputs.functionAppName.value" \
                --output tsv 2>/dev/null)
            
            FUNCTION_URL=$(az deployment group show \
                --resource-group "rg-crud-serverless-villavih" \
                --name "crud-app-deployment-v2" \
                --query "properties.outputs.functionAppUrl.value" \
                --output tsv 2>/dev/null)
            
            WEBAPP_NAME=$(az deployment group show \
                --resource-group "rg-crud-serverless-villavih" \
                --name "crud-app-deployment-v2" \
                --query "properties.outputs.staticWebAppName.value" \
                --output tsv 2>/dev/null)
            
            echo "🔗 Function App: $FUNCTION_APP"
            echo "🔗 Function URL: $FUNCTION_URL"
            echo "🔗 Static Web App: $WEBAPP_NAME"
            echo ""
            echo "🚀 PRÓXIMOS COMANDOS A EJECUTAR:"
            echo ""
            echo "1. Desplegar Backend:"
            echo "   cd ../backend"
            echo "   ./deploy-backend.sh $FUNCTION_APP"
            echo ""
            echo "2. Desplegar Frontend:"
            echo "   cd ../frontend"
            echo "   ./deploy-frontend.sh $WEBAPP_NAME $FUNCTION_URL"
            echo ""
            break
            
        elif [ "$STATE" = "Failed" ]; then
            echo "❌ DEPLOYMENT FALLÓ"
            echo ""
            echo "📋 Error:"
            az deployment group show \
                --resource-group "rg-crud-serverless-villavih" \
                --name "crud-app-deployment-v2" \
                --query "properties.error.message" \
                --output tsv 2>/dev/null
            break
            
        elif [ "$STATE" = "Running" ]; then
            echo "⏳ Deployment en progreso..."
        else
            echo "❓ Estado desconocido: $STATE"
        fi
    else
        echo "⚠️ No se pudo obtener el estado del deployment"
    fi
    
    echo "   Próxima verificación en 30 segundos... (Ctrl+C para salir)"
    echo ""
    sleep 30
done
