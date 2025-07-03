#!/bin/bash

echo "🔧 SOLUCIONANDO PROBLEMA DEL TOKEN DE STATIC WEB APP"
echo "===================================================="
echo ""

# Variables
RESOURCE_GROUP="rg-crud-serverless-villavih"
STATIC_WEB_APP_NAME="crudapp-web-prod-ckp33m"
REPO_URL="https://github.com/VillaviH/proyecto-serverless-azure"

echo "🔍 PROBLEMA IDENTIFICADO:"
echo "   ❌ GitHub Actions Error: 'No matching Static Web App was found or the api key was invalid'"
echo "   ❌ El token AZURE_STATIC_WEB_APPS_API_TOKEN no coincide con la Static Web App actual"
echo ""

echo "🚀 SOLUCIONES DISPONIBLES:"
echo "   1. Actualizar token en GitHub (RECOMENDADO)"
echo "   2. Deployment manual con SWA CLI"
echo "   3. Recrear Static Web App desde cero"
echo ""

read -p "¿Qué opción prefieres? (1/2/3): " -n 1 -r
echo ""

case $REPLY in
    1)
        echo ""
        echo "📋 OPCIÓN 1: Actualizar token en GitHub"
        echo "======================================"
        echo ""
        echo "🔑 Paso 1: Obteniendo token correcto de Azure..."
        
        # Obtener el token correcto
        echo "Ejecutando: az staticwebapp secrets list..."
        TOKEN=$(az staticwebapp secrets list \
            --name "$STATIC_WEB_APP_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --query 'properties.apiKey' \
            --output tsv 2>/dev/null)
        
        if [ ! -z "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
            echo "✅ Token obtenido exitosamente"
            echo ""
            echo "📋 Paso 2: Configurar token en GitHub"
            echo "====================================="
            echo ""
            echo "1. Ve a: $REPO_URL/settings/secrets/actions"
            echo "2. Busca: AZURE_STATIC_WEB_APPS_API_TOKEN"
            echo "3. Haz clic en 'Update' o 'Add repository secret'"
            echo "4. Pega este token (copialo ahora):"
            echo ""
            echo "🔑 TOKEN:"
            echo "$TOKEN"
            echo ""
            echo "5. Guarda el secreto"
            echo "6. Haz un nuevo commit para activar GitHub Actions:"
            echo "   git commit --allow-empty -m 'Trigger deployment with correct token'"
            echo "   git push origin main"
            echo ""
            echo "⏰ El deployment se activará automáticamente en 1-2 minutos"
        else
            echo "❌ Error obteniendo token de Azure"
            echo "   Probando opción 2 (deployment manual)..."
            REPLY=2
        fi
        ;;
    2)
        echo ""
        echo "📋 OPCIÓN 2: Deployment manual con SWA CLI"
        echo "=========================================="
        echo ""
        echo "🔑 Obteniendo token para deployment manual..."
        
        TOKEN=$(az staticwebapp secrets list \
            --name "$STATIC_WEB_APP_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --query 'properties.apiKey' \
            --output tsv 2>/dev/null)
        
        if [ ! -z "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
            echo "✅ Token obtenido"
            echo ""
            echo "📦 Preparando deployment..."
            
            cd frontend
            
            # Verificar que el build existe
            if [ ! -d "out" ]; then
                echo "🏗️  Build no encontrado, compilando..."
                npm run build
            fi
            
            echo "✅ Build verificado"
            echo ""
            echo "🚀 Desplegando con SWA CLI..."
            
            # Instalar SWA CLI si no existe
            if ! command -v swa &> /dev/null; then
                echo "📦 Instalando SWA CLI..."
                npm install -g @azure/static-web-apps-cli
            fi
            
            # Deployment
            swa deploy out --deployment-token "$TOKEN" --env production
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "✅ ¡DEPLOYMENT EXITOSO!"
                echo "🌐 Verifica tu aplicación en:"
                echo "   https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
            else
                echo "❌ Error en deployment manual"
                echo "   Probando opción 3..."
                REPLY=3
            fi
            
            cd ..
        else
            echo "❌ Error obteniendo token"
            echo "   Probando opción 3..."
            REPLY=3
        fi
        ;;
    3)
        echo ""
        echo "📋 OPCIÓN 3: Recrear Static Web App"
        echo "=================================="
        echo ""
        echo "⚠️  Esta opción eliminará la Static Web App actual y creará una nueva"
        echo ""
        read -p "¿Estás seguro? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "🗑️  Eliminando Static Web App actual..."
            az staticwebapp delete \
                --name "$STATIC_WEB_APP_NAME" \
                --resource-group "$RESOURCE_GROUP" \
                --yes
            
            echo "✅ Static Web App eliminada"
            echo ""
            echo "📋 PASOS MANUALES REQUERIDOS:"
            echo "============================"
            echo ""
            echo "1. Ve al portal de Azure: https://portal.azure.com"
            echo "2. Busca 'Static Web Apps' y haz clic en 'Create'"
            echo "3. Configuración:"
            echo "   - Subscription: Azure subscription 1"
            echo "   - Resource Group: $RESOURCE_GROUP"
            echo "   - Name: $STATIC_WEB_APP_NAME"
            echo "   - Plan: Free"
            echo "   - Region: East US 2"
            echo "   - Source: GitHub"
            echo "   - Repository: VillaviH/proyecto-serverless-azure"
            echo "   - Branch: main"
            echo "   - App location: /frontend"
            echo "   - Build location: /frontend/out"
            echo ""
            echo "4. Haz clic en 'Review + Create' y luego 'Create'"
            echo "5. Azure configurará automáticamente GitHub Actions"
            echo "6. El nuevo token se agregará automáticamente a GitHub"
            echo ""
            echo "⏰ Tiempo estimado: 5-10 minutos"
        else
            echo "❌ Operación cancelada"
        fi
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

echo ""
echo "🔍 VERIFICACIÓN FINAL:"
echo "====================="
echo ""
echo "Prueba estas URLs en unos minutos:"
echo "✅ Backend:  https://crudapp-api-prod-ckp33m.azurewebsites.net/api/tasks"
echo "🔄 Frontend: https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo ""
echo "Comandos de verificación:"
echo "curl -I https://crudapp-api-prod-ckp33m.azurewebsites.net/api/tasks"
echo "curl -I https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
echo ""
echo "🎯 ¡Tu aplicación estará funcionando completamente en breve!"
