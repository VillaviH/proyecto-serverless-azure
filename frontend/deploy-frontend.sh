#!/bin/bash

# Script para configurar y desplegar el frontend a Azure Static Web Apps
set -e

echo "🌐 Configurando y desplegando Frontend (Next.js + Azure Static Web Apps)..."

# Variables
STATIC_WEB_APP_NAME="$1"
FUNCTION_APP_URL="$2"
RESOURCE_GROUP_NAME="rg-crud-serverless-villavih"

if [ -z "$STATIC_WEB_APP_NAME" ] || [ -z "$FUNCTION_APP_URL" ]; then
    echo "❌ Error: Se requieren el nombre de la Static Web App y la URL del backend"
    echo "Uso: ./deploy-frontend.sh <STATIC_WEB_APP_NAME> <FUNCTION_APP_URL>"
    echo "Ejemplo: ./deploy-frontend.sh crud-demo-web-dev-abc123 https://crud-demo-api-dev-abc123.azurewebsites.net"
    exit 1
fi

echo "📍 Static Web App: $STATIC_WEB_APP_NAME"
echo "📍 Backend URL: $FUNCTION_APP_URL"
echo "📍 Resource Group: $RESOURCE_GROUP_NAME"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Asegúrate de estar en el directorio frontend."
    exit 1
fi

echo "🔧 Configurando variables de entorno para producción..."

# Crear archivo .env.production con la URL correcta del backend
cat > .env.production << EOF
NEXT_PUBLIC_API_URL=$FUNCTION_APP_URL/api
NODE_ENV=production
EOF

echo "✅ Archivo .env.production creado:"
cat .env.production
echo ""

echo "📦 Instalando dependencias..."
npm ci

echo "🏗️  Construyendo aplicación para producción..."
npm run build

echo "📋 Verificando build..."
if [ ! -d "out" ]; then
    echo "❌ Error: No se generó el directorio 'out'. Verifica la configuración de Next.js."
    exit 1
fi

echo "✅ Build completado. Archivos generados en 'out/'"
echo ""

echo "🚀 Desplegando a Azure Static Web App..."
echo "   Opción 1: Despliegue directo con Azure CLI"
echo "   Opción 2: Conectar con repositorio GitHub (recomendado)"
echo ""

read -p "¿Deseas proceder con el despliegue directo? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Iniciando despliegue directo..."
    
    # Verificar si Azure Static Web Apps CLI está instalado
    if ! command -v swa &> /dev/null; then
        echo "⚠️  Azure Static Web Apps CLI no está instalado."
        echo "🔧 Instalando..."
        npm install -g @azure/static-web-apps-cli
    fi
    
    # Desplegar usando SWA CLI
    swa deploy \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --app-name "$STATIC_WEB_APP_NAME" \
        --app-location "." \
        --output-location "out" \
        --deployment-token $(az staticwebapp secrets list \
            --name "$STATIC_WEB_APP_NAME" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --query "properties.apiKey" \
            --output tsv)
    
    echo ""
    echo "✅ ¡Despliegue completado!"
    
else
    echo "📋 Para conectar con GitHub:"
    echo ""
    echo "1. Sube tu código a un repositorio GitHub"
    echo "2. Ve a Azure Portal > Static Web Apps > $STATIC_WEB_APP_NAME"
    echo "3. Ve a 'Deployment' > 'GitHub'"
    echo "4. Conecta tu repositorio"
    echo "5. Azure creará automáticamente el workflow de GitHub Actions"
    echo ""
    echo "📁 Configuración recomendada para GitHub Actions:"
    echo "   - App location: '/frontend'"
    echo "   - Api location: ''"
    echo "   - Output location: 'out'"
    echo ""
fi

echo ""
echo "🎉 ¡Configuración del frontend completada!"
echo ""
echo "🔗 URLs importantes:"
echo "   Backend API: $FUNCTION_APP_URL"
echo "   Frontend (cuando termine el despliegue): https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo ""
echo "📋 Próximos pasos:"
echo "1. Esperar a que termine el despliegue"
echo "2. Probar la aplicación en la URL del frontend"
echo "3. Verificar logs en Application Insights"
