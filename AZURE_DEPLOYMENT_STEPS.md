# 🚀 Pasos para Desplegar en Azure - CRUD Serverless

## ✅ Estado Actual
- [✅] **Infraestructura**: Recursos desplegados en Azure
- [✅] **Backend**: Código corregido, compilado y listo para ejecutar
- [✅] **Frontend**: Configurado y listo para desarrollo local

---

## 🚀 PASO ACTUAL: Levantar Backend Local

### 1. ✅ Backend Local (EJECUTAR AHORA)

El backend Azure Functions está compilado y listo. Para iniciarlo:

```bash
# Navegar al directorio backend
cd backend

# Opción 1: Script automatizado
./start-local.sh

# Opción 2: Comando directo
func start --cors "http://localhost:3000"
```

**URLs del Backend:**
- **Local**: http://localhost:7071/api
- **Producción**: https://crudapp-api-prod-ckp33m.azurewebsites.net/api

### 2. 🧪 Probar Backend Local

```bash
# En otra terminal, probar el endpoint
curl http://localhost:7071/api/tasks

# Debería devolver: [] (lista vacía de tareas)
```

### 3. ✅ Verificar Dependencias

```bash
# Verificar que todo esté instalado
./check-dependencies.sh
```

**Estado de dependencias:**
- ✅ .NET SDK 8.0.404
- ✅ Azure Functions Core Tools 4.0.7317  
- ✅ Node.js v23.11.0
- ✅ Compilación exitosa

---

## 📋 Pasos a Seguir

### 1. ✅ Infraestructura (EN PROCESO)
```bash
# Ya ejecutado:
az group create --name "rg-crud-serverless-villavih" --location "East US"
az deployment group create --resource-group "rg-crud-serverless-villavih" --template-file bicep/main.bicep --parameters bicep/main.parameters.json
```

**Recursos que se están creando:**
- Azure Functions App (Backend API)
- Azure SQL Database (Serverless)
- Azure Static Web Apps (Frontend)
- Application Insights (Monitoring)
- Storage Account
- App Service Plan

### 2. 🔄 **SIGUIENTE: Publicar Backend**

Una vez que termine el despliegue de infraestructura:

```bash
# 1. Obtener el nombre de la Function App creada
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "crud-demo-deployment-YYYYMMDD-HHMMSS" \
  --query properties.outputs.functionAppName.value \
  --output tsv

# 2. Publicar el backend
cd backend
func azure functionapp publish [FUNCTION_APP_NAME]
```

### 3. 🔄 **SIGUIENTE: Configurar Frontend para Producción**

```bash
# 1. Obtener la URL de la Function App
FUNCTION_URL=$(az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "crud-demo-deployment-YYYYMMDD-HHMMSS" \
  --query properties.outputs.functionAppUrl.value \
  --output tsv)

# 2. Actualizar configuración del frontend
echo "NEXT_PUBLIC_API_URL=$FUNCTION_URL" > frontend/.env.production
```

### 4. 🔄 **SIGUIENTE: Desplegar Frontend**

**Opción A: Manual Upload**
```bash
cd frontend
npm run build
# Subir manualmente la carpeta 'out' a Azure Static Web Apps
```

**Opción B: GitHub Actions (Recomendado)**
```bash
# 1. Hacer push del código a GitHub
git add .
git commit -m "Deploy to Azure"
git push origin main

# 2. Configurar GitHub Actions en Azure Static Web Apps
```

---

## 🚀 PASO ACTUAL: Levantar Frontend

### 1. ✅ Frontend Local (EJECUTAR AHORA)

El frontend Next.js ya está configurado y listo. Para iniciarlo en desarrollo:

```bash
# Navegar al directorio frontend
cd frontend

# Opción 1: Usar el script automatizado
./start-dev.sh

# Opción 2: Comando directo
npm run dev
```

**URLs del Frontend:**
- **Local**: http://localhost:3000
- **Producción**: https://crudapp-web-prod-ckp33m.azurestaticapps.net (después del deploy)

### 2. 🔍 Verificar Frontend

```bash
# Verificar estado
./check-frontend.sh

# Abrir en browser
open http://localhost:3000
```

### 3. 🔧 Configuración API

El frontend está configurado para usar:
- **Desarrollo**: `http://localhost:7071/api` (Azure Functions local)
- **Producción**: `https://crudapp-api-prod-ckp33m.azurewebsites.net/api`

---

## 🎯 URLs Finales

Una vez completado el despliegue:

- **Backend API**: `https://[FUNCTION_APP_NAME].azurewebsites.net`
- **Frontend Web**: `https://[STATIC_WEB_APP_NAME].azurestaticapps.net`
- **Base de Datos**: `[SQL_SERVER_NAME].database.windows.net`

---

## 🚨 Próximos Comandos a Ejecutar

```bash
# 1. Verificar estado del despliegue
az deployment group show --resource-group "rg-crud-serverless-villavih" --name [DEPLOYMENT_NAME]

# 2. Obtener outputs del despliegue
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name [DEPLOYMENT_NAME] \
  --query properties.outputs

# 3. Publicar backend
cd backend && func azure functionapp publish [FUNCTION_APP_NAME]

# 4. Actualizar frontend y desplegar
cd frontend && echo "NEXT_PUBLIC_API_URL=https://[FUNCTION_APP_NAME].azurewebsites.net" > .env.production
```

---

## ⚡ Comandos de Verificación

```bash
# Verificar recursos creados
az resource list --resource-group "rg-crud-serverless-villavih" --output table

# Verificar Function App
az functionapp list --resource-group "rg-crud-serverless-villavih" --output table

# Verificar Static Web App
az staticwebapp list --resource-group "rg-crud-serverless-villavih" --output table

# Verificar SQL Server
az sql server list --resource-group "rg-crud-serverless-villavih" --output table
```

---

## 📝 Notas Importantes

1. **El despliegue de infraestructura puede tomar 5-10 minutos**
2. **Guarda los nombres de los recursos generados** (tienen un sufijo único)
3. **La Function App necesita ser publicada por separado** con Azure Functions Core Tools
4. **El frontend se puede desplegar via GitHub Actions** para automatización completa

---

*Este archivo se actualizará conforme avance el proceso de despliegue.*
