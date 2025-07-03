#!/bin/bash

echo "🔍 Monitoreando GitHub Actions..."
echo "=================================="

# Obtener la URL del repositorio
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(echo "$REPO_URL" | sed 's/.*github.com[:/]\([^.]*\).*/\1/')

echo "📦 Repositorio: $REPO_NAME"
echo ""

# Verificar que gh CLI esté instalado
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) no está instalado. Instalando..."
    if command -v brew &> /dev/null; then
        brew install gh
    else
        echo "❌ Por favor instala GitHub CLI manualmente: https://cli.github.com/"
        exit 1
    fi
fi

# Verificar autenticación con GitHub
if ! gh auth status &> /dev/null; then
    echo "🔑 Autenticándose con GitHub..."
    gh auth login
fi

echo "🔄 Estado de los workflows recientes:"
echo "======================================"
gh run list --limit 5

echo ""
echo "🔍 Último workflow:"
echo "==================="
gh run view $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') || echo "No hay workflows recientes"

echo ""
echo "📊 Estado de la Static Web App:"
echo "==============================="
curl -I https://crudapp-web-prod-ckp33m.azurestaticapps.net 2>/dev/null | head -3

echo ""
echo "💡 Comando para ver logs en tiempo real:"
echo "gh run watch"
