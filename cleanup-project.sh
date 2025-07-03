#!/bin/bash

echo "🧹 LIMPIEZA AUTOMÁTICA DEL PROYECTO"
echo "===================================="
echo ""
echo "Este script eliminará archivos obsoletos y temporales"
echo "manteniendo solo los archivos esenciales para el proyecto."
echo ""

read -p "¿Continuar con la limpieza? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Limpieza cancelada"
    exit 0
fi

echo ""
echo "🗑️ Eliminando archivos obsoletos..."

# Documentación obsoleta
echo "📄 Eliminando documentación obsoleta..."
rm -f AZURE_DEPLOYMENT_STEPS.md BUILD_FIXES.md CURRENT_STATUS.md
rm -f DEPLOYMENT_GUIDE.md DEPLOYMENT_STATUS.md DEPLOYMENT_SUCCESS.md
rm -f EJECUTAR_BACKEND.txt FINAL_BUILD_FIXES.md GITHUB_INTEGRATION_GUIDE.md
rm -f GUIA_DESPLIEGUE_AZURE.md INSTRUCCIONES_EJECUTAR.txt INSTRUCCIONES_FINALES.md
rm -f MANUAL_VERIFICATION.md NEXT_STEPS.md PROBLEMA_RESUELTO.md
rm -f QUICK_START.md TROUBLESHOOTING_404.md

# Scripts obsoletos raíz
echo "🔧 Eliminando scripts obsoletos..."
rm -f check-deployment-status.sh check-project.sh check-status.sh
rm -f deploy-to-azure.sh fix-swa-token.sh monitor-github-actions.sh
rm -f setup-github-integration.sh start-frontend.sh start-local.sh

# Scripts backend obsoletos
echo "⚙️ Eliminando scripts backend obsoletos..."
rm -f backend/check-backend.sh backend/check-dependencies.sh
rm -f backend/deploy-backend.sh backend/diagnose-backend.sh
rm -f backend/start-local.sh

# Scripts frontend obsoletos
echo "🌐 Eliminando scripts frontend obsoletos..."
rm -f frontend/check-frontend.sh frontend/deploy-alternative.sh
rm -f frontend/deploy-frontend.sh frontend/deploy-production.sh
rm -f frontend/start-dev.sh frontend/upload-to-swa.sh

# Scripts infrastructure obsoletos
echo "🏗️ Eliminando scripts infrastructure obsoletos..."
rm -f infrastructure/check-deployment.sh infrastructure/check-deployment-fixed.sh
rm -f infrastructure/check-latest.sh infrastructure/deploy.sh
rm -f infrastructure/monitor-current.sh infrastructure/monitor-deployment.sh
rm -f infrastructure/monitor-v3.sh infrastructure/simple-check.sh

# Archivos temporales
echo "🗂️ Eliminando archivos temporales..."
rm -rf logs/
rm -f frontend/frontend-build.tar.gz
rm -f infrastructure/bicep/missing-resources.bicep
rm -f backend/azure.settings.json

# Archivos de entorno locales (opcionales)
echo "⚡ Eliminando archivos de entorno locales..."
rm -f frontend/.env.production

echo ""
echo "✅ ¡LIMPIEZA COMPLETADA!"
echo "======================="
echo ""
echo "📊 Archivos eliminados:"
echo "   📄 Documentación obsoleta: ~15 archivos"
echo "   🔧 Scripts obsoletos: ~25 archivos"
echo "   🗂️ Archivos temporales: ~5 archivos"
echo ""
echo "✅ Archivos mantenidos (esenciales):"
echo "   📝 Código fuente: backend/ + frontend/src/"
echo "   🏗️ Infraestructura: infrastructure/bicep/"
echo "   🔧 Scripts principales: deploy-step-by-step.sh, start-dev.sh, etc."
echo "   📋 Configuración: package.json, .csproj, workflows, etc."
echo "   📖 Documentación: README.md, DESPLIEGUE_EXITOSO.md"
echo ""
echo "🎯 Proyecto limpio y profesional listo para mantener."
echo ""
echo "💡 Próximo paso recomendado:"
echo "   git add . && git commit -m 'Clean up project - remove obsolete files'"
