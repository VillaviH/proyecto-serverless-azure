# Proyecto CRUD Serverless Azure

## Descripción
Este es un proyecto de demostración que implementa un CRUD completo utilizando:
- **Frontend**: Next.js 14 con TypeScript y Tailwind CSS
- **Backend**: .NET Core 8 con Azure Functions
- **Base de Datos**: Azure SQL Database
- **Infraestructura**: Azure Serverless (Functions, Static Web Apps, SQL Database)

## Arquitectura
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Next.js App   │    │  Azure Functions │    │ Azure SQL DB    │
│ (Static Web App)│───▶│   (.NET Core 8)  │───▶│   (Serverless)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Estructura del Proyecto
```
├── README.md
├── backend/                    # Azure Functions (.NET Core 8)
│   ├── TaskApi/
│   ├── host.json
│   └── local.settings.json
├── frontend/                   # Next.js Application
│   ├── src/
│   ├── package.json
│   └── next.config.js
└── infrastructure/             # Azure Infrastructure as Code
    ├── bicep/
    └── terraform/
```

## Funcionalidades del CRUD
El proyecto implementa un sistema de gestión de tareas con las siguientes operaciones:
- ✅ **Create**: Crear nuevas tareas
- ✅ **Read**: Listar y ver detalles de tareas
- ✅ **Update**: Editar tareas existentes
- ✅ **Delete**: Eliminar tareas

## Modelo de Datos
```csharp
public class Task
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
```

## Configuración Local

### Prerrequisitos
- Node.js 18+
- .NET Core 8 SDK
- Azure CLI
- Azure Functions Core Tools

### Backend (.NET Core 8 + Azure Functions)
```bash
cd backend
func start
```

### Frontend (Next.js)
```bash
cd frontend
npm install
npm run dev
```

## Despliegue en Azure

### 1. Infraestructura
```bash
cd infrastructure
# Utilizando Bicep
az deployment group create --resource-group rg-crud-demo --template-file main.bicep
```

### 2. Backend
```bash
cd backend
func azure functionapp publish crud-api-functions
```

### 3. Frontend
```bash
cd frontend
npm run build
# Deploy to Azure Static Web Apps
```

## Variables de Entorno

### Backend (local.settings.json)
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "SqlConnectionString": "Server=tcp:your-server.database.windows.net,1433;Database=TasksDB;User ID=admin;Password=YourPassword;Encrypt=true;"
  }
}
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=https://your-function-app.azurewebsites.net/api
```

## Endpoints de la API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/tasks` | Obtener todas las tareas |
| GET | `/api/tasks/{id}` | Obtener una tarea por ID |
| POST | `/api/tasks` | Crear una nueva tarea |
| PUT | `/api/tasks/{id}` | Actualizar una tarea |
| DELETE | `/api/tasks/{id}` | Eliminar una tarea |

## Tecnologías Utilizadas

### Frontend
- Next.js 14
- TypeScript
- Tailwind CSS
- React Hook Form
- Axios

### Backend
- .NET Core 8
- Azure Functions
- Entity Framework Core
- Azure SQL Database

### Infraestructura
- Azure Functions
- Azure Static Web Apps
- Azure SQL Database
- Azure Resource Manager (Bicep)

## Características Serverless

### Beneficios
- **Escalabilidad automática**: Se escala según la demanda
- **Costo optimizado**: Solo pagas por lo que usas
- **Mantenimiento mínimo**: Azure gestiona la infraestructura
- **Alta disponibilidad**: Distribución global automática

### Limitaciones
- **Cold start**: Posible latencia en la primera ejecución
- **Tiempo de ejecución**: Límite de 10 minutos por función
- **Conexiones DB**: Gestión del pool de conexiones

## Próximos Pasos
- [ ] Implementar autenticación con Azure AD B2C
- [ ] Añadir tests unitarios y de integración
- [ ] Configurar CI/CD con GitHub Actions
- [ ] Implementar logging y monitoring
- [ ] Añadir cache con Azure Redis

## Contribución
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.