#!/bin/bash

# Script para verificar el estado del despliegue en Azure
set -e

echo "🔍 Verificando Estado del Despliegue en Azure"
echo "=============================================="
echo ""

# Variables
RESOURCE_GROUP="rg-crud-serverless-villavih"

# Verificar login
SUBSCRIPTION=$(az account show --query "name" --output tsv 2>/dev/null || echo "")
if [ -z "$SUBSCRIPTION" ]; then
    echo "❌ No estás autenticado en Azure"
    echo "   Ejecuta: az login"
    exit 1
fi

echo "✅ Conectado a Azure"
echo "📋 Suscripción: $SUBSCRIPTION"
echo ""

# Obtener recursos
echo "🔍 Buscando recursos en $RESOURCE_GROUP..."

FUNCTION_APP_NAME=$(az functionapp list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv | head -1)
STATIC_WEB_APP_NAME=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv | head -1)
SQL_SERVER_NAME=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[?contains(name, 'crudapp')].name" -o tsv | head -1)

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo "❌ No se encontró Function App"
else
    echo "✅ Function App: $FUNCTION_APP_NAME"
fi

if [ -z "$STATIC_WEB_APP_NAME" ]; then
    echo "❌ No se encontró Static Web App"
else
    echo "✅ Static Web App: $STATIC_WEB_APP_NAME"
fi

if [ -z "$SQL_SERVER_NAME" ]; then
    echo "❌ No se encontró SQL Server"
else
    echo "✅ SQL Server: $SQL_SERVER_NAME"
fi

echo ""

# Verificar estado del backend
if [ ! -z "$FUNCTION_APP_NAME" ]; then
    echo "🔧 Verificando estado del backend..."
    
    BACKEND_STATE=$(az functionapp show --name "$FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "state" -o tsv)
    BACKEND_URL="https://${FUNCTION_APP_NAME}.azurewebsites.net"
    
    echo "   Estado: $BACKEND_STATE"
    echo "   URL: $BACKEND_URL"
    
    echo "   🌐 Probando API..."
    API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${BACKEND_URL}/api/tasks" 2>/dev/null || echo "ERROR")
    
    if [ "$API_RESPONSE" = "200" ] || [ "$API_RESPONSE" = "204" ]; then
        echo "   ✅ API responde correctamente (código: $API_RESPONSE)"
    elif [ "$API_RESPONSE" = "404" ]; then
        echo "   ⚠️  API responde 404 - verifica el deployment"
    else
        echo "   ❌ API no responde (código: $API_RESPONSE)"
    fi
    
    echo ""
fi

# Verificar estado del frontend
if [ ! -z "$STATIC_WEB_APP_NAME" ]; then
    echo "🌐 Verificando estado del frontend..."
    
    FRONTEND_URL="https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"
    
    echo "   URL: $FRONTEND_URL"
    
    # Obtener información de la Static Web App
    SWA_INFO=$(az staticwebapp show --name "$STATIC_WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "{repositoryUrl: repositoryUrl, branch: branch, buildProperties: buildProperties}" 2>/dev/null || echo "{}")
    
    echo "   Repositorio: $(echo $SWA_INFO | jq -r '.repositoryUrl // "No configurado"')"
    echo "   Rama: $(echo $SWA_INFO | jq -r '.branch // "No configurado"')"
    
    echo "   🌐 Probando frontend..."
    FRONTEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "ERROR")
    
    if [ "$FRONTEND_RESPONSE" = "200" ]; then
        echo "   ✅ Frontend responde correctamente"
    elif [ "$FRONTEND_RESPONSE" = "404" ]; then
        echo "   ❌ Frontend responde 404 - verifica GitHub Actions"
    else
        echo "   ⚠️  Frontend responde con código: $FRONTEND_RESPONSE"
    fi
    
    # Verificar environments
    echo "   🔍 Verificando environments..."
    ENVIRONMENTS=$(az staticwebapp environment list --name "$STATIC_WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "[].{name: name, hostname: hostname, status: status}" -o table 2>/dev/null || echo "Error obteniendo environments")
    
    if [ "$ENVIRONMENTS" != "Error obteniendo environments" ]; then
        echo "$ENVIRONMENTS"
    else
        echo "   ⚠️  No se pudieron obtener los environments"
    fi
    
    echo ""
fi

# Verificar estado de la base de datos
if [ ! -z "$SQL_SERVER_NAME" ]; then
    echo "🗄️  Verificando estado de la base de datos..."
    
    DB_STATE=$(az sql server show --name "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" --query "state" -o tsv 2>/dev/null || echo "Error")
    
    if [ "$DB_STATE" != "Error" ]; then
        echo "   Estado del servidor: $DB_STATE"
        
        # Listar bases de datos
        DATABASES=$(az sql db list --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv 2>/dev/null || echo "Error")
        
        if [ "$DATABASES" != "Error" ]; then
            echo "   Bases de datos:"
            echo "$DATABASES" | while read db; do
                echo "     - $db"
            done
        fi
    else
        echo "   ❌ Error accediendo al servidor SQL"
    fi
    
    echo ""
fi

# Resumen final
echo "📊 RESUMEN DEL ESTADO"
echo "===================="

if [ ! -z "$FUNCTION_APP_NAME" ] && [ ! -z "$STATIC_WEB_APP_NAME" ]; then
    echo ""
    echo "🌐 URLs de tu aplicación:"
    echo "   🔧 Backend:  https://${FUNCTION_APP_NAME}.azurewebsites.net/api"
    echo "   📱 Frontend: https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"
    if [ ! -z "$SQL_SERVER_NAME" ]; then
        echo "   🗄️  Database: ${SQL_SERVER_NAME}.database.windows.net"
    fi
    
    echo ""
    echo "🧪 Comandos de prueba:"
    echo "   curl https://${FUNCTION_APP_NAME}.azurewebsites.net/api/tasks"
    echo "   curl https://${STATIC_WEB_APP_NAME}.azurestaticapps.net"
    
    echo ""
    echo "📚 Recursos útiles:"
    echo "   Ver logs backend: func azure functionapp logstream $FUNCTION_APP_NAME"
    echo "   Reiniciar backend: az functionapp restart --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP"
    echo "   Ver deployment SWA: az staticwebapp show --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP"
    
    if [[ $SWA_INFO == *"github.com"* ]]; then
        REPO_URL=$(echo $SWA_INFO | jq -r '.repositoryUrl')
        if [ "$REPO_URL" != "null" ]; then
            echo "   GitHub Actions: ${REPO_URL}/actions"
        fi
    fi
else
    echo "❌ Faltan recursos críticos - ejecuta el script de despliegue"
fi

echo ""
echo "✅ Verificación completada"
