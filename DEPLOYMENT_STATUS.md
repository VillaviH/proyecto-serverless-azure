# 🚀 Estado del Despliegue en Azure

## ✅ APLICACIÓN LOCAL LISTA CON SCRIPT MAESTRO

### 🎯 EJECUTAR TODO CON UN SOLO COMANDO:

```bash
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure
./start-dev.sh
```

**¡Un solo script inicia tanto el backend como el frontend!**

### 🌐 URLs de la Aplicación Local:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:7071/api
- **API Test**: http://localhost:7071/api/tasks

### 🛠️ Comandos de Gestión:

```bash
# Iniciar toda la aplicación
./start-dev.sh

# Verificar estado de servicios
./status-dev.sh

# Detener todos los servicios
./stop-dev.sh
```

### ✅ Características del Script Maestro:
- 🔄 Inicia backend y frontend automáticamente
- 📊 Verifica dependencias antes de iniciar
- 📝 Genera logs separados para cada servicio
- 🧹 Limpieza automática al detener
- ⚡ Monitoreo continuo de procesos
- 🔧 Configuración automática de CORS

### 📋 Lo que hace el script:
1. Verifica dependencias (.NET, Node.js, Azure Functions)
2. Compila el backend (.NET)
3. Instala dependencias del frontend (si es necesario)
4. Inicia backend en puerto 7071
5. Inicia frontend en puerto 3000
6. Configura CORS automáticamente
7. Monitorea ambos servicios
8. Proporciona URLs y comandos útiles

---

## ⏳ INFRAESTRUCTURA AZURE EN PARALELO

La infraestructura de Azure sigue desplegándose en paralelo:

### Comando en ejecución:
```bash
az deployment group create \
  --resource-group "rg-crud-serverless-villavih" \
  --template-file bicep/main.bicep \
  --parameters bicep/main.parameters.json \
  --name "crud-demo-deployment-20250702"
```

### Para verificar el estado:
```bash
az deployment group show \
  --resource-group "rg-crud-serverless-villavih" \
  --name "crud-demo-deployment-20250702" \
  --query "properties.provisioningState"
```

## 🔜 Próximos Pasos Automáticos

1. **Cuando termine el despliegue**:
   - Obtener los nombres de los recursos creados
   - Configurar y publicar el backend
   - Configurar y desplegar el frontend

2. **Scripts preparados**:
   - Script para publicar backend a Azure Functions
   - Configuración para desplegar frontend a Static Web Apps
   - URLs de producción se generarán automáticamente

## 📋 Recursos que se están creando:
- Azure Functions (Backend API)
- Azure SQL Database (Base de datos serverless)
- Azure Static Web Apps (Frontend)
- Application Insights (Monitoreo)
- Log Analytics Workspace
- Storage Account

---
**Tiempo estimado**: 5-10 minutos
**Estado actual**: Desplegando infraestructura... ⏳
