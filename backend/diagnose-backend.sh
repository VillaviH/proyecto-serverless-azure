#!/bin/bash

# Script para diagnosticar problemas en el backend Azure Function
set -e

echo "🔍 Diagnóstico del Backend Azure Function..."

FUNCTION_APP_NAME="$1"
RESOURCE_GROUP_NAME="rg-crud-serverless-villavih"

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo "❌ Error: Se requiere el nombre de la Function App"
    echo "Uso: ./diagnose-backend.sh <FUNCTION_APP_NAME>"
    echo "Ejemplo: ./diagnose-backend.sh crudapp-api-prod-ckp33m"
    exit 1
fi

echo "📍 Function App: $FUNCTION_APP_NAME"
echo "📍 Resource Group: $RESOURCE_GROUP_NAME"
echo ""

# 1. Verificar estado de la Function App
echo "1️⃣ Verificando estado de la Function App..."
az functionapp show \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "{name:name, state:state, defaultHostName:defaultHostName, kind:kind}" \
    --output table

echo ""

# 2. Verificar configuración de la aplicación
echo "2️⃣ Verificando configuración de variables de entorno..."
az functionapp config appsettings list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "[?name=='FUNCTIONS_WORKER_RUNTIME' || name=='SqlConnectionString' || name=='WEBSITE_RUN_FROM_PACKAGE'].{Name:name, Value:value}" \
    --output table

echo ""

# 3. Verificar logs recientes
echo "3️⃣ Verificando logs recientes (últimos 50 eventos)..."
az functionapp logs tail \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --filter "timestamp ge datetime'$(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ)'" \
    --top 50 \
    --output table \
    || echo "⚠️ No se pudieron obtener logs. Intentando método alternativo..."

echo ""

# 4. Verificar conexión HTTP básica
echo "4️⃣ Verificando conectividad HTTP básica..."
FUNCTION_URL="https://$FUNCTION_APP_NAME.azurewebsites.net"
echo "Probando: $FUNCTION_URL"

# Verificar que la Function App responde
response=$(curl -s -w "%{http_code}" -o /dev/null "$FUNCTION_URL" || echo "000")
if [ "$response" -eq "200" ] || [ "$response" -eq "404" ]; then
    echo "✅ Function App responde (HTTP $response)"
else
    echo "❌ Function App no responde (HTTP $response)"
fi

echo ""

# 5. Probar endpoint específico
echo "5️⃣ Probando endpoint de tareas..."
API_URL="$FUNCTION_URL/api/tasks"
echo "Probando: $API_URL"

response=$(curl -s -w "%{http_code}" -o /tmp/api_response.txt "$API_URL" || echo "000")
echo "HTTP Status: $response"

if [ -f "/tmp/api_response.txt" ]; then
    echo "Respuesta:"
    cat /tmp/api_response.txt
    echo ""
    rm -f /tmp/api_response.txt
fi

echo ""

# 6. Comandos útiles para continuar diagnóstico
echo "🛠️ Comandos adicionales para diagnóstico:"
echo ""
echo "Ver logs en tiempo real:"
echo "func azure functionapp logstream $FUNCTION_APP_NAME"
echo ""
echo "Reiniciar Function App:"
echo "az functionapp restart --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
echo ""
echo "Ver métricas de la Function App:"
echo "az monitor metrics list --resource /subscriptions/\$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Web/sites/$FUNCTION_APP_NAME --metric-names \"Requests,Http5xx,ResponseTime\""
echo ""

echo "✅ Diagnóstico completado."
