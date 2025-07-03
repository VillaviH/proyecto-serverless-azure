#!/bin/bash

# Script para monitorear el progreso del despliegue en tiempo real

set -e

RESOURCE_GROUP="rg-crud-serverless-villavih"

echo "🔍 Monitoreando despliegues en Azure..."
echo "📍 Grupo de recursos: $RESOURCE_GROUP"
echo ""

while true; do
    clear
    echo "🔍 Estado del despliegue - $(date)"
    echo "=================================="
    echo ""
    
    # Verificar si el grupo de recursos existe
    if az group exists --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
        echo "✅ Grupo de recursos: $RESOURCE_GROUP existe"
        echo ""
        
        # Listar todos los despliegues
        echo "📋 Despliegues activos:"
        az deployment group list \
            --resource-group "$RESOURCE_GROUP" \
            --query "[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}" \
            --output table 2>/dev/null || echo "No se encontraron despliegues"
        
        echo ""
        
        # Verificar el último despliegue
        LATEST_DEPLOYMENT=$(az deployment group list \
            --resource-group "$RESOURCE_GROUP" \
            --query "[0].name" \
            --output tsv 2>/dev/null)
        
        if [ "$LATEST_DEPLOYMENT" != "" ] && [ "$LATEST_DEPLOYMENT" != "null" ]; then
            DEPLOYMENT_STATE=$(az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$LATEST_DEPLOYMENT" \
                --query "properties.provisioningState" \
                --output tsv 2>/dev/null)
            
            echo "🚀 Último despliegue: $LATEST_DEPLOYMENT"
            echo "📊 Estado: $DEPLOYMENT_STATE"
            
            if [ "$DEPLOYMENT_STATE" = "Succeeded" ]; then
                echo ""
                echo "🎉 ¡DESPLIEGUE COMPLETADO EXITOSAMENTE!"
                echo ""
                echo "🔗 Próximos pasos:"
                echo "1. Presiona Ctrl+C para salir de este monitor"
                echo "2. Ejecuta: ./check-deployment.sh"
                echo "3. Sigue las instrucciones para desplegar backend y frontend"
                break
            elif [ "$DEPLOYMENT_STATE" = "Failed" ]; then
                echo ""
                echo "❌ DESPLIEGUE FALLÓ"
                echo ""
                echo "📋 Error:"
                az deployment group show \
                    --resource-group "$RESOURCE_GROUP" \
                    --name "$LATEST_DEPLOYMENT" \
                    --query "properties.error.message" \
                    --output tsv 2>/dev/null || echo "No se pudo obtener el mensaje de error"
                break
            else
                echo "⏳ Despliegue en progreso..."
            fi
        else
            echo "⚠️  No se encontraron despliegues activos"
            echo "   Verifica que el comando de despliegue se esté ejecutando"
        fi
        
    else
        echo "❌ Grupo de recursos no encontrado: $RESOURCE_GROUP"
        echo "   Verifica que el grupo de recursos se haya creado correctamente"
    fi
    
    echo ""
    echo "🔄 Actualizando en 30 segundos... (Ctrl+C para salir)"
    sleep 30
done
