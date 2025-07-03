# 🚀 Guía Completa de Despliegue a Azure

## ✅ Estado Actual
- ✅ **Aplicación local**: Funcionando correctamente
- ✅ **Código revisado**: Optimizado para Azure
- ✅ **Scripts creados**: Listos para despliegue

## 🔧 Cambios Realizados para Azure

### 1. **Backend (.NET + Azure Functions)**
✅ **Program.cs**: Configurado con retry policy para SQL
✅ **Database**: Configurado para usar Azure SQL en producción
✅ **CORS**: Habilitado para Azure Static Web Apps
✅ **Logging**: Integrado con Application Insights

### 2. **Frontend (Next.js + Static Web Apps)**
✅ **next.config.js**: Configurado con `output: 'export'` para Azure
✅ **Configuración**: Variables de entorno para producción
✅ **Build**: Optimizado para Azure Static Web Apps
✅ **Routing**: SPA routing configurado

### 3. **Infraestructura (Bicep)**
✅ **Azure Functions**: Runtime .NET 8 isolated
✅ **Azure SQL**: Base de datos serverless
✅ **Static Web Apps**: Para el frontend
✅ **Application Insights**: Monitoreo y logs
✅ **Storage Account**: Para Azure Functions

## 🚀 Opciones de Despliegue

### Opción 1: Script Automático Completo
```bash
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure
./deploy-to-azure.sh
```
**Tiempo estimado**: 15-20 minutos
**Requiere**: Confirmaciones mínimas

### Opción 2: Script Paso a Paso (RECOMENDADO)
```bash
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure
./deploy-step-by-step.sh
```
**Tiempo estimado**: 20-25 minutos
**Ventajas**: Control total, explicaciones detalladas

### Opción 3: Manual (Para expertos)
1. `cd infrastructure && az deployment group create...`
2. `cd backend && func azure functionapp publish...`
3. Configurar frontend y desplegar manualmente

## 📋 Pre-requisitos

### ✅ Ya verificados:
- Azure CLI instalado y configurado
- .NET SDK 8.0.404
- Azure Functions Core Tools 4.0.7317
- Node.js v23.11.0

### 🔐 Autenticación:
```bash
# Si no estás autenticado:
az login

# Verificar suscripción activa:
az account show
```

## 🎯 Proceso de Despliegue (Paso a Paso)

### FASE 1: Infraestructura (5-8 minutos)
1. **Crear grupo de recursos**
2. **Validar template Bicep**
3. **Desplegar recursos**:
   - Azure Functions App
   - Azure SQL Database (serverless)
   - Static Web App
   - Application Insights
   - Storage Account

### FASE 2: Backend (3-5 minutos)
1. **Compilar código .NET**
2. **Configurar variables de entorno**:
   - SqlConnectionString
   - FUNCTIONS_WORKER_RUNTIME
3. **Desplegar a Azure Functions**
4. **Reiniciar Function App**

### FASE 3: Frontend (2-3 minutos)
1. **Configurar variables para producción**
2. **Compilar Next.js**
3. **Generar archivos estáticos**

### FASE 4: Verificación (2-3 minutos)
1. **Probar API endpoints**
2. **Verificar conectividad**
3. **Mostrar URLs finales**

## 🌐 URLs Resultantes

Después del despliegue tendrás:

- **🔧 Backend API**: `https://crudapp-api-prod-XXXXXX.azurewebsites.net/api`
- **📱 Frontend**: `https://crudapp-web-prod-XXXXXX.azurestaticapps.net`
- **🗄️ Database**: `crudapp-sql-prod-XXXXXX.database.windows.net`

## 🧪 Endpoints de la API

```bash
# Obtener todas las tareas
GET https://tu-function-app.azurewebsites.net/api/tasks

# Crear nueva tarea
POST https://tu-function-app.azurewebsites.net/api/tasks
Content-Type: application/json
{
  "title": "Mi tarea",
  "description": "Descripción de la tarea"
}

# Actualizar tarea
PUT https://tu-function-app.azurewebsites.net/api/tasks/{id}
Content-Type: application/json
{
  "title": "Tarea actualizada",
  "description": "Nueva descripción",
  "isCompleted": true
}

# Eliminar tarea
DELETE https://tu-function-app.azurewebsites.net/api/tasks/{id}
```

## 🔧 Comandos Útiles Post-Despliegue

```bash
# Ver logs en tiempo real
func azure functionapp logstream [FUNCTION_APP_NAME]

# Reiniciar Function App
az functionapp restart --name [FUNCTION_APP_NAME] --resource-group rg-crud-serverless-villavih

# Ver recursos desplegados
az resource list --resource-group rg-crud-serverless-villavih --output table

# Eliminar todo (si es necesario)
az group delete --name rg-crud-serverless-villavih --yes --no-wait
```

## 📊 Monitoreo y Logs

- **Application Insights**: Métricas automáticas
- **Azure Portal**: Panel de control completo
- **Function App Logs**: Logs en tiempo real
- **SQL Database**: Métricas de rendimiento

## 💰 Costos Estimados

Con la configuración serverless:
- **Azure Functions**: ~$0.20/millón de ejecuciones
- **Azure SQL**: ~$1-5/mes (serverless)
- **Static Web Apps**: Gratis hasta 100GB bandwidth
- **Application Insights**: ~$1-3/mes
- **Storage**: ~$0.50/mes

**Total estimado**: $5-10/mes para desarrollo/testing

## 🚨 Solución de Problemas

### Backend no responde:
1. `func azure functionapp logstream [FUNCTION_APP_NAME]`
2. Verificar cadena de conexión SQL
3. Reiniciar Function App

### Frontend no conecta con backend:
1. Verificar `NEXT_PUBLIC_API_URL` en producción
2. Revisar configuración CORS
3. Verificar que el backend esté disponible

### Errores de base de datos:
1. Verificar firewall de SQL Server
2. Verificar credenciales de conexión
3. Revisar logs de Application Insights

## 🎯 ¡LISTO PARA DESPLEGAR!

**Ejecuta el comando:**
```bash
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure
./deploy-step-by-step.sh
```

**¿Todo listo? ¡Empezamos el despliegue!** 🚀
