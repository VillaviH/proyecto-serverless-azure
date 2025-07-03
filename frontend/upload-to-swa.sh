#!/bin/bash

# Script simplificado para subir el frontend a Azure Static Web Apps
set -e

echo "🌐 Desplegando Frontend a Azure Static Web Apps..."

# Variables
STATIC_WEB_APP_NAME="crudapp-web-prod-ckp33m"
RESOURCE_GROUP="rg-crud-serverless-villavih"
BUILD_DIR="out"

# Verificar que el build existe
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Error: Directorio $BUILD_DIR no existe. Ejecuta 'npm run build' primero."
    exit 1
fi

echo "📂 Directorio de build: $BUILD_DIR"
echo "🎯 Static Web App: $STATIC_WEB_APP_NAME"
echo ""

# Método 1: Usar Azure CLI directamente
echo "🚀 Intentando despliegue con Azure CLI..."

# Obtener el deployment token
echo "🔑 Obteniendo token de despliegue..."
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.apiKey" -o tsv)

if [ -z "$DEPLOYMENT_TOKEN" ]; then
    echo "❌ No se pudo obtener el token de despliegue"
    exit 1
fi

echo "✅ Token obtenido"

# Crear un archivo zip con el contenido
echo "📦 Empaquetando archivos..."
cd $BUILD_DIR
zip -r ../swa-build.zip . > /dev/null 2>&1
cd ..

echo "✅ Archivos empaquetados"

# Subir usando curl (método directo)
echo "⬆️ Subiendo a Azure Static Web Apps..."

# URL de la API de despliegue
SWA_DEPLOYMENT_URL="https://api.azurestaticapps.net/api/deploy"

# Realizar el upload
curl -X POST \
  -H "Authorization: Bearer $DEPLOYMENT_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @swa-build.zip \
  "$SWA_DEPLOYMENT_URL" \
  -o deployment-response.json

if [ $? -eq 0 ]; then
    echo "✅ Despliegue iniciado exitosamente"
    echo "📄 Respuesta guardada en deployment-response.json"
    
    # Mostrar la URL de la aplicación
    echo ""
    echo "🌍 URL de la aplicación:"
    az staticwebapp show --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP --query "defaultHostname" -o tsv | xargs -I {} echo "   https://{}"
    
    echo ""
    echo "⏳ El despliegue puede tardar unos minutos en completarse."
    echo "   Verifica el estado en Azure Portal o espera unos minutos y prueba la URL."
else
    echo "❌ Error en el despliegue"
    exit 1
fi

# Limpiar archivos temporales
rm -f swa-build.zip deployment-response.json

echo ""
echo "🎉 ¡Despliegue completado!"
