#!/bin/bash

# Script para configurar repositorio GitHub y vincular a Azure Static Web Apps
set -e

echo "🔗 Configurando repositorio GitHub para Azure Static Web Apps"
echo "============================================================"
echo ""

# Variables
REPO_NAME="proyecto-serverless-azure"
GITHUB_USERNAME="VillaviH"  # Cambia esto por tu usuario de GitHub
STATIC_WEB_APP_NAME="crudapp-web-prod-ckp33m"
RESOURCE_GROUP="rg-crud-serverless-villavih"

echo "📝 PASO 1: Crear repositorio en GitHub"
echo "======================================="
echo ""
echo "1. Ve a GitHub.com y crea un nuevo repositorio:"
echo "   Nombre: $REPO_NAME"
echo "   Tipo: Público o Privado (tu elección)"
echo "   NO inicialices con README (ya tienes código)"
echo ""
echo "2. Copia la URL del repositorio (ejemplo):"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo ""

echo "📤 PASO 2: Subir código al repositorio"
echo "======================================"
echo ""
echo "Ejecuta estos comandos desde la raíz del proyecto:"
echo ""
cat << 'EOF'
# Inicializar Git (si no está inicializado)
git init

# Agregar archivos al staging
git add .

# Hacer commit inicial
git commit -m "Initial commit: CRUD Serverless App with Azure Functions and Next.js"

# Agregar remote origin (sustituye TU_USUARIO por tu usuario de GitHub)
git remote add origin https://github.com/VillaviH/proyecto-serverless-azure.git

# Crear y cambiar a rama main
git branch -M main

# Subir código a GitHub
git push -u origin main
EOF

echo ""
echo "🔧 PASO 3: Configurar GitHub Actions"
echo "===================================="
echo ""
echo "Crea el archivo .github/workflows/azure-static-web-apps.yml:"
echo ""

# Crear directorio para GitHub Actions
mkdir -p .github/workflows

# Crear archivo de workflow para GitHub Actions
cat > .github/workflows/azure-static-web-apps.yml << 'EOF'
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
          lfs: false
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/frontend"
          api_location: ""
          output_location: "out"
        env:
          NEXT_PUBLIC_API_URL: "https://crudapp-api-prod-ckp33m.azurewebsites.net/api"
          NODE_ENV: "production"

  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
EOF

echo "✅ Archivo de GitHub Actions creado: .github/workflows/azure-static-web-apps.yml"
echo ""

echo "🔑 PASO 4: Obtener token de Azure Static Web Apps"
echo "================================================="
echo ""
echo "Ejecuta este comando para obtener el token:"
echo ""
echo "az staticwebapp secrets list --name $STATIC_WEB_APP_NAME --resource-group $RESOURCE_GROUP --query 'properties.apiKey' -o tsv"
echo ""

echo "📝 PASO 5: Configurar secreto en GitHub"
echo "======================================="
echo ""
echo "1. Ve a tu repositorio en GitHub"
echo "2. Ve a Settings > Secrets and variables > Actions"
echo "3. Clic en 'New repository secret'"
echo "4. Nombre: AZURE_STATIC_WEB_APPS_API_TOKEN"
echo "5. Valor: [pega el token obtenido en el paso 4]"
echo "6. Clic en 'Add secret'"
echo ""

echo "🔗 PASO 6: Vincular repositorio a Azure Static Web Apps"
echo "======================================================="
echo ""
echo "Ejecuta este comando:"
echo ""
echo "az staticwebapp update \\"
echo "  --name $STATIC_WEB_APP_NAME \\"
echo "  --resource-group $RESOURCE_GROUP \\"
echo "  --source https://github.com/$GITHUB_USERNAME/$REPO_NAME \\"
echo "  --branch main \\"
echo "  --app-location '/frontend' \\"
echo "  --output-location 'out'"
echo ""

echo "✅ PASO 7: Verificar funcionamiento"
echo "==================================="
echo ""
echo "Después de configurar todo:"
echo ""
echo "1. Haz un push a la rama main:"
echo "   git add ."
echo "   git commit -m 'Add GitHub Actions workflow'"
echo "   git push origin main"
echo ""
echo "2. Ve a GitHub > Actions para ver el deployment en progreso"
echo ""
echo "3. Una vez completado, la app estará en:"
echo "   https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo ""

echo "🎉 COMPLETADO"
echo "============="
echo ""
echo "Una vez configurado, tendrás:"
echo "✅ URL personalizada activa: https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo "✅ Despliegue automático con cada push a main"
echo "✅ Preview deployments para pull requests"
echo "✅ Historial de deployments en GitHub Actions"
echo ""
