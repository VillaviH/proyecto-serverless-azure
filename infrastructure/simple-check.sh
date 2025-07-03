#!/bin/bash

# Script ultra-simple para verificar el último deployment

RESOURCE_GROUP="rg-crud-serverless-villavih"

echo "🔍 Verificando deployments en $RESOURCE_GROUP..."
echo ""

# Verificar si el grupo existe
if az group exists --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "✅ Grupo de recursos existe"
    
    # Listar todos los deployments
    echo ""
    echo "📋 Deployments encontrados:"
    az deployment group list --resource-group "$RESOURCE_GROUP" --output table
    
    echo ""
    echo "📋 Recursos en el grupo:"
    az resource list --resource-group "$RESOURCE_GROUP" --output table
    
else
    echo "❌ Grupo de recursos no existe"
    echo "   Creando grupo de recursos..."
    az group create --name "$RESOURCE_GROUP" --location "East US 2"
fi
