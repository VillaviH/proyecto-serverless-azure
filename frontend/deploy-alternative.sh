#!/bin/bash

# Script alternativo para subir el frontend usando Azure REST API
set -e

echo "🌐 Despliegue Alternativo del Frontend..."

# Variables
STATIC_WEB_APP_NAME="crudapp-web-prod-ckp33m"
RESOURCE_GROUP="rg-crud-serverless-villavih"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "📋 Información del despliegue:"
echo "   Static Web App: $STATIC_WEB_APP_NAME"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Subscription: $SUBSCRIPTION_ID"
echo ""

# Verificar que el build existe
if [ ! -d "out" ]; then
    echo "❌ Error: Directorio 'out' no existe. Ejecuta 'npm run build' primero."
    exit 1
fi

# Método alternativo: usar az rest directamente
echo "🚀 Iniciando despliegue..."

# Crear un archivo tar con el contenido
echo "📦 Empaquetando contenido..."
cd out
tar -czf ../frontend-build.tar.gz *
cd ..

echo "✅ Contenido empaquetado"

# Obtener access token
ACCESS_TOKEN=$(az account get-access-token --query accessToken -o tsv)

# URL de la API REST de Azure
API_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/staticSites/$STATIC_WEB_APP_NAME"

echo "🔍 Verificando estado de la Static Web App..."
curl -s -X GET \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "$API_URL?api-version=2022-03-01" | jq '.properties.defaultHostname' || echo "API response received"

echo ""
echo "📤 Intentando subir contenido..."

# Intentar upload usando la API de gestión
curl -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @frontend-build.tar.gz \
  "$API_URL/builds?api-version=2022-03-01" \
  -o upload-response.json

if [ $? -eq 0 ]; then
    echo "✅ Respuesta del servidor recibida"
    echo "📄 Respuesta guardada en upload-response.json"
else
    echo "⚠️ Respuesta del servidor inesperada"
fi

# Limpiar archivos temporales
rm -f frontend-build.tar.gz

echo ""
echo "🌍 URL de la aplicación:"
echo "   https://happy-grass-00f8dff0f.2.azurestaticapps.net"
echo ""
echo "📝 Nota: Si el despliegue no funciona inmediatamente,"
echo "   puedes usar GitHub Actions para el despliegue automático."
echo ""
echo "🔧 Para configurar GitHub Actions:"
echo "   1. Sube el código a un repositorio de GitHub"
echo "   2. Conecta el repositorio en Azure Portal"
echo "   3. Azure creará automáticamente el workflow de GitHub Actions"
