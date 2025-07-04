#!/bin/bash

echo "🧹 LIMPIEZA INTELIGENTE DE ARCHIVOS"
echo "=================================="
echo ""

echo "🔍 ARCHIVOS A MANTENER (ESENCIALES):"
echo "====================================="
echo "✅ .github/workflows/azure-static-web-apps.yml (GitHub Actions)"
echo "✅ backend/ (Código del backend)"
echo "✅ frontend/ (Código del frontend)"
echo "✅ infrastructure/ (Infraestructura Bicep)"
echo "✅ staticwebapp.config.json (Configuración SWA)"
echo "✅ README.md (Documentación principal)"
echo "✅ .gitignore (Control de versiones)"
echo ""

echo "🗑️  ARCHIVOS A ELIMINAR (OBSOLETOS/DEBUG):"
echo "=========================================="
echo "❌ cleanup-project.sh (Ya no necesario)"
echo "❌ emergency-fix.sh (Temporal, ya resuelto)"
echo "❌ fix-api-url.sh (Temporal, ya resuelto)"
echo "❌ monitor-deploy.sh (Temporal)"
echo "❌ monitor-deployment.sh (Temporal)"
echo "❌ start-dev.sh (Puede ser recreado si es necesario)"
echo "❌ status-dev.sh (Temporal)"
echo "❌ stop-dev.sh (Temporal)"
echo "❌ ultimate-fix.sh (Temporal)"
echo "❌ verify-deployment.sh (Temporal)"
echo "❌ CLEANUP_GUIDE.md (Ya no necesario)"
echo "❌ SOLUCION_LOCALHOST.md (Ya resuelto)"
echo ""

echo "📋 ARCHIVOS A MANTENER PERO REVISAR:"
echo "===================================="
echo "⚠️  deploy-step-by-step.sh (Útil para redeploys manuales)"
echo "⚠️  DESPLIEGUE_EXITOSO.md (Documentación del proceso)"
echo "⚠️  proyecto-serverless-azure.sln (Solo si usas Visual Studio)"
echo ""

read -p "¿Proceder con la limpieza? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Limpieza cancelada"
    exit 0
fi

echo ""
echo "🧹 INICIANDO LIMPIEZA..."

# Crear backup por seguridad
echo "📦 Creando backup de seguridad..."
mkdir -p .backup-$(date +%Y%m%d)
cp *.sh .backup-$(date +%Y%m%d)/ 2>/dev/null || true
cp *.md .backup-$(date +%Y%m%d)/ 2>/dev/null || true
echo "✅ Backup creado en .backup-$(date +%Y%m%d)/"

# Eliminar archivos de debug/temporales
echo ""
echo "🗑️  Eliminando archivos temporales..."

FILES_TO_DELETE=(
    "cleanup-project.sh"
    "emergency-fix.sh"
    "fix-api-url.sh"
    "monitor-deploy.sh"
    "monitor-deployment.sh"
    "status-dev.sh"
    "stop-dev.sh"
    "ultimate-fix.sh"
    "verify-deployment.sh"
    "CLEANUP_GUIDE.md"
    "SOLUCION_LOCALHOST.md"
)

for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "🗑️  Eliminado: $file"
    fi
done

echo ""
echo "🤔 ARCHIVOS OPCIONALES:"
echo "======================"

# Preguntar por archivos opcionales
if [ -f "start-dev.sh" ]; then
    read -p "¿Eliminar start-dev.sh? (Solo si no desarrollas localmente) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "start-dev.sh"
        echo "🗑️  Eliminado: start-dev.sh"
    else
        echo "✅ Mantenido: start-dev.sh"
    fi
fi

if [ -f "proyecto-serverless-azure.sln" ]; then
    read -p "¿Eliminar proyecto-serverless-azure.sln? (Solo si no usas Visual Studio) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "proyecto-serverless-azure.sln"
        echo "🗑️  Eliminado: proyecto-serverless-azure.sln"
    else
        echo "✅ Mantenido: proyecto-serverless-azure.sln"
    fi
fi

echo ""
echo "🧹 LIMPIANDO DIRECTORIOS..."

# Limpiar archivos temporales en backend
if [ -d "backend/bin" ]; then
    echo "🗑️  Limpiando backend/bin/"
    rm -rf backend/bin/Debug backend/bin/Release 2>/dev/null || true
fi

if [ -d "backend/obj" ]; then
    echo "🗑️  Limpiando backend/obj/"
    rm -rf backend/obj/Debug backend/obj/Release 2>/dev/null || true
fi

# Limpiar archivos temporales en frontend
if [ -d "frontend/node_modules" ]; then
    echo "🗑️  Limpiando frontend/node_modules/ (se puede reinstalar con npm install)"
    rm -rf frontend/node_modules/
fi

if [ -d "frontend/.next" ]; then
    echo "🗑️  Limpiando frontend/.next/"
    rm -rf frontend/.next/
fi

if [ -d "frontend/out" ]; then
    echo "🗑️  Limpiando frontend/out/"
    rm -rf frontend/out/
fi

# Limpiar logs
find . -name "*.log" -type f -delete 2>/dev/null || true
echo "🗑️  Eliminados archivos .log"

echo ""
echo "🎉 LIMPIEZA COMPLETADA"
echo "====================="
echo ""

echo "✅ ARCHIVOS ESENCIALES MANTENIDOS:"
echo "📁 backend/ - Código del API (.NET)"
echo "📁 frontend/ - Código del frontend (Next.js)"
echo "📁 infrastructure/ - Definición de infraestructura (Bicep)"
echo "📁 .github/workflows/ - GitHub Actions para CI/CD"
echo "📄 staticwebapp.config.json - Configuración de Azure Static Web Apps"
echo "📄 README.md - Documentación principal"
echo ""

if [ -f "deploy-step-by-step.sh" ]; then
    echo "📄 deploy-step-by-step.sh - Script de despliegue manual (mantenido)"
fi

if [ -f "DESPLIEGUE_EXITOSO.md" ]; then
    echo "📄 DESPLIEGUE_EXITOSO.md - Documentación del despliegue (mantenido)"
fi

echo ""
echo "🔄 PARA RESTAURAR DEPENDENCIAS:"
echo "==============================="
echo "Frontend: cd frontend && npm install"
echo "Backend:  cd backend && dotnet restore"
echo ""

echo "🚀 TU APLICACIÓN SIGUE FUNCIONANDO:"
echo "==================================="
echo "🌐 Frontend: https://happy-bush-0a20fda0f.2.azurestaticapps.net"
echo "🔧 Backend:  https://crudapp-api-prod-ckp33m.azurewebsites.net/api"
echo ""

echo "💡 Si necesitas algún archivo eliminado, está en .backup-$(date +%Y%m%d)/"
