# 🚀 Guía para Levantar el Backend Local

## ✅ Estado de Dependencias
- ✅ .NET SDK 8.0.404
- ✅ Azure Functions Core Tools 4.0.7317
- ✅ Node.js v23.11.0
- ✅ Compilación exitosa

## 📋 Pasos para Iniciar el Backend

### 1. Abrir una nueva terminal
```bash
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure/backend
```

### 2. Opción A: Usar el script automatizado
```bash
./start-local.sh
```

### 3. Opción B: Comandos manuales
```bash
# Limpiar y compilar
dotnet clean
dotnet restore
dotnet build

# Iniciar Azure Functions
func start --cors "http://localhost:3000"
```

## 🌐 URLs del Backend Local

Una vez iniciado, el backend estará disponible en:
- **Base URL**: http://localhost:7071
- **API Base**: http://localhost:7071/api

## 📋 Endpoints Disponibles

- `GET /api/tasks` - Obtener todas las tareas
- `GET /api/tasks/{id}` - Obtener tarea por ID
- `POST /api/tasks` - Crear nueva tarea
- `PUT /api/tasks/{id}` - Actualizar tarea
- `DELETE /api/tasks/{id}` - Eliminar tarea

## 🧪 Probar el Backend

### Comando de prueba rápida:
```bash
# En otra terminal, probar el endpoint
curl http://localhost:7071/api/tasks
```

**Respuesta esperada:** Una lista JSON (posiblemente vacía `[]`)

## 🔧 Configuración Actual

- **Runtime**: dotnet-isolated
- **Base de Datos**: InMemory (para desarrollo local)
- **CORS**: Habilitado para http://localhost:3000

## 🚨 Si hay problemas

1. **Puerto ocupado**: El puerto 7071 puede estar en uso
   ```bash
   lsof -ti:7071 | xargs kill -9
   ```

2. **Errores de compilación**: Verificar dependencias
   ```bash
   dotnet --version
   func --version
   ```

3. **Problemas de CORS**: Asegurar que CORS esté configurado correctamente

## 🎯 Siguiente Paso

Una vez que el backend esté corriendo:
1. ✅ Backend en http://localhost:7071
2. 🚀 Iniciar frontend en http://localhost:3000
3. 🧪 Probar la aplicación completa

---

**💡 Consejo**: Mantén esta terminal abierta mientras desarrollas. El backend se reiniciará automáticamente cuando hagas cambios en el código.
