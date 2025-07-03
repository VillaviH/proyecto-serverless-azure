# Proyecto CRUD Serverless Azure - Guía de Inicio Rápido

## 🚀 Inicio Rápido

### Prerrequisitos
- Node.js 18+
- .NET 8 SDK
- Azure CLI
- Azure Functions Core Tools v4

### Instalación Local

1. **Clonar e instalar dependencias:**
```bash
# Instalar Azure Functions Core Tools
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Ir al directorio del proyecto
cd proyecto-serverless-azure

# Ejecutar la aplicación completa
./start-local.sh
```

2. **Acceder a la aplicación:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:7071/api

### Despliegue en Azure

1. **Autenticarse en Azure:**
```bash
az login
```

2. **Desplegar infraestructura:**
```bash
cd infrastructure
./deploy.sh
```

3. **Desplegar código del backend:**
```bash
cd backend
func azure functionapp publish [FUNCTION_APP_NAME]
```

4. **Desplegar frontend:**
- Conectar el repositorio con Azure Static Web Apps
- O usar GitHub Actions para CI/CD automático

## 🛠️ Desarrollo

### Backend (.NET Core 8)
```bash
cd backend
dotnet restore
func start
```

### Frontend (Next.js)
```bash
cd frontend
npm install
npm run dev
```

## 📊 Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Static Web    │    │  Azure Functions │    │ Azure SQL DB    │
│    App (SWA)    │───▶│   (.NET Core 8)  │───▶│   (Serverless)  │
│   Next.js 14    │    │    Serverless    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🔧 Configuración

### Variables de Entorno

**Backend (local.settings.json):**
```json
{
  "Values": {
    "SqlConnectionString": "Server=(localdb)\\mssqllocaldb;Database=TasksDB;Trusted_Connection=true;"
  }
}
```

**Frontend (.env.local):**
```env
NEXT_PUBLIC_API_URL=http://localhost:7071/api
```

## 📱 Funcionalidades

- ✅ **Crear** nuevas tareas
- ✅ **Leer** lista de tareas y detalles
- ✅ **Actualizar** tareas existentes
- ✅ **Eliminar** tareas
- ✅ **Marcar como completada**
- ✅ **Interfaz responsiva**
- ✅ **Validación de formularios**
- ✅ **Manejo de errores**

## 🌐 Endpoints API

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/tasks` | Obtener todas las tareas |
| GET | `/api/tasks/{id}` | Obtener tarea por ID |
| POST | `/api/tasks` | Crear nueva tarea |
| PUT | `/api/tasks/{id}` | Actualizar tarea |
| DELETE | `/api/tasks/{id}` | Eliminar tarea |

## 🏗️ Infraestructura Serverless

### Servicios de Azure Utilizados:
- **Azure Functions** - Backend API serverless
- **Azure Static Web Apps** - Frontend hosting
- **Azure SQL Database** - Base de datos serverless
- **Application Insights** - Monitoreo y telemetría

### Beneficios Serverless:
- **Costo optimizado** - Solo pagas por uso
- **Escalabilidad automática** - Se adapta a la demanda
- **Mantenimiento mínimo** - Azure gestiona la infraestructura
- **Alta disponibilidad** - Redundancia global

## 🔍 Monitoreo

La aplicación incluye:
- Application Insights para telemetría
- Logging estructurado
- Métricas de rendimiento
- Alertas configurables

## 🚦 Estados de Desarrollo

- ✅ **Backend API** - Completado
- ✅ **Frontend UI** - Completado  
- ✅ **Base de Datos** - Completado
- ✅ **Infraestructura** - Completado
- ✅ **Documentación** - Completado

## 📞 Soporte

Para problemas o preguntas:
1. Revisa la documentación
2. Verifica los logs en Application Insights
3. Consulta los issues en GitHub
