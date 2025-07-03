#!/bin/bash

# Script para desplegar directamente a producción en Azure Static Web Apps
set -e

echo "🚀 Desplegando Frontend a Producción en Azure Static Web Apps"
echo "============================================================="

# Variables
STATIC_WEB_APP_NAME="crudapp-web-prod-ckp33m"
BACKEND_URL="https://crudapp-api-prod-ckp33m.azurewebsites.net"
RESOURCE_GROUP="rg-crud-serverless-villavih"

# Verificar directorio
if [ ! -f "package.json" ]; then
    echo "❌ Error: Ejecutar desde el directorio frontend"
    exit 1
fi

echo "📍 Static Web App: $STATIC_WEB_APP_NAME"
echo "📍 Backend URL: $BACKEND_URL"
echo ""

# 1. Configurar variables de entorno para producción
echo "🔧 Configurando variables de entorno..."
cat > .env.production << EOF
NEXT_PUBLIC_API_URL=$BACKEND_URL/api
NODE_ENV=production
EOF

echo "✅ Variables configuradas:"
cat .env.production
echo ""

# 2. Limpiar build anterior
echo "🧹 Limpiando build anterior..."
rm -rf .next out dist

# 3. Instalar dependencias
echo "📦 Instalando dependencias..."
npm ci

# 4. Build para producción
echo "🔨 Generando build estático..."
npm run build

# Verificar que el build se generó
if [ ! -d "out" ]; then
    echo "❌ Error: No se generó el directorio 'out'"
    exit 1
fi

echo "✅ Build generado en directorio 'out'"
echo ""

# 5. Comprimir el contenido
echo "📦 Preparando archivos para deployment..."
cd out
tar -czf ../frontend-build.tar.gz *
cd ..

echo "✅ Archivos comprimidos: frontend-build.tar.gz"

# 6. Obtener token de deployment
echo "🔑 Obteniendo token de deployment..."
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP --query "properties.apiKey" -o tsv)

if [ -z "$DEPLOYMENT_TOKEN" ]; then
    echo "❌ Error: No se pudo obtener el token de deployment"
    exit 1
fi

echo "✅ Token obtenido"
echo ""

# 7. Desplegar usando Static Web Apps CLI
echo "🚀 Desplegando a Azure Static Web Apps..."

# Instalar SWA CLI si no está instalado
if ! command -v swa &> /dev/null; then
    echo "📦 Instalando Azure Static Web Apps CLI..."
    npm install -g @azure/static-web-apps-cli
fi

# Desplegar a producción (slot por defecto)
echo "📤 Subiendo archivos..."
swa deploy out \
    --deployment-token "$DEPLOYMENT_TOKEN" \
    --env production

echo ""
echo "🎉 ¡Deployment completado!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🌐 URLs de la aplicación:"
echo "   Producción: https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo "   Backend:    $BACKEND_URL"
echo ""
echo "🔍 Verificar deployment:"
echo "   curl -I https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo ""
echo "⏳ Nota: Puede tomar unos minutos para que los cambios se reflejen"
echo "════════════════════════════════════════════════════════════"
