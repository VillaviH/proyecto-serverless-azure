# 🔍 Verificación Manual del Deployment en Azure

## Estado Actual
El deployment de infraestructura está ejecutándose o ya terminó. Vamos a verificarlo paso a paso.

## Paso 1: Verificar Estado del Deployment

Ejecuta este comando para ver si el deployment terminó:

```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "crud-app-deployment" \
  --query "properties.provisioningState" \
  --output tsv
```

**Posibles resultados:**
- `Succeeded` ✅ = ¡Deployment exitoso! Continúa al Paso 2
- `Running` ⏳ = Todavía en progreso, espera unos minutos y vuelve a ejecutar
- `Failed` ❌ = Algo falló, ve al Paso 4 para diagnóstico

## Paso 2: Obtener Información de los Recursos (Solo si fue exitoso)

Si el estado es `Succeeded`, ejecuta estos comandos:

### 2.1 Obtener nombre de la Function App:
```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "final-deployment" \
  --query "properties.outputs.functionAppName.value" \
  --output tsv
```

### 2.2 Obtener URL de la Function App:
```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "final-deployment" \
  --query "properties.outputs.functionAppUrl.value" \
  --output tsv
```

### 2.3 Obtener nombre de la Static Web App:
```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "final-deployment" \
  --query "properties.outputs.staticWebAppName.value" \
  --output tsv
```

## Paso 3: Desplegar Backend (Solo si Paso 2 fue exitoso)

Con los nombres obtenidos en el Paso 2:

```bash
cd ../backend
./deploy-backend.sh [NOMBRE_DE_FUNCTION_APP]
```

Ejemplo:
```bash
cd ../backend
./deploy-backend.sh crud-demo-villavih-api-prod-abc123
```

## Paso 4: Desplegar Frontend (Solo después del Paso 3)

```bash
cd ../frontend
./deploy-frontend.sh [NOMBRE_STATIC_WEB_APP] [URL_FUNCTION_APP]
```

Ejemplo:
```bash
cd ../frontend
./deploy-frontend.sh crud-demo-villavih-web-prod-abc123 https://crud-demo-villavih-api-prod-abc123.azurewebsites.net
```

## Paso 5: Verificar que Todo Funciona

### 5.1 Probar Backend:
```bash
curl [URL_FUNCTION_APP]/api/tasks
```

### 5.2 Abrir Frontend en el navegador:
```
https://[NOMBRE_STATIC_WEB_APP].azurestaticapps.net
```

## Diagnóstico de Problemas

### Si el deployment falló (estado = "Failed"):
```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "final-deployment" \
  --query "properties.error"
```

### Ver todos los recursos creados:
```bash
az resource list --resource-group "rg-crud-serverless-villavih" --output table
```

## Script Automático (Alternativo)

Si prefieres, también puedes usar:
```bash
cd infrastructure
./check-latest.sh
```

---

**¡Empezar por el Paso 1 y seguir las instrucciones según el resultado!**
