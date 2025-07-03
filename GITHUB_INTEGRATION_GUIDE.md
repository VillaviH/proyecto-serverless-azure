# 🔗 Guía Completa: Vincular GitHub para URL Personalizada

## 📋 Resumen
Esta guía te ayudará a vincular tu repositorio de GitHub a Azure Static Web Apps para que el frontend se ejecute en la URL personalizada: `https://crudapp-web-prod-ckp33m.azurestaticapps.net`

---

## 🚀 PASO 1: Crear Repositorio en GitHub

### 1.1 Crear el repositorio
1. Ve a [GitHub.com](https://github.com) y haz login
2. Clic en "New repository" (botón verde)
3. Configuración del repositorio:
   - **Repository name**: `proyecto-serverless-azure`
   - **Description**: `CRUD Serverless App with Azure Functions and Next.js`
   - **Visibility**: Público o Privado (tu elección)
   - **NO marques** "Add a README file" (ya tienes código)
   - **NO agregues** .gitignore ni license por ahora
4. Clic en "Create repository"

### 1.2 Copiar la URL del repositorio
Después de crear el repositorio, copia la URL que aparece. Será algo como:
```
https://github.com/TU_USUARIO/proyecto-serverless-azure.git
```

---

## 📤 PASO 2: Subir tu Código a GitHub

Ejecuta estos comandos desde la raíz de tu proyecto:

```bash
# Ir al directorio del proyecto
cd /Users/villavih/Documents/DATAFAST/proyecto-serverless-azure

# Inicializar Git (si no está inicializado)
git init

# Agregar todos los archivos
git add .

# Hacer commit inicial
git commit -m "Initial commit: CRUD Serverless App with Azure Functions and Next.js"

# Agregar remote origin (SUSTITUYE TU_USUARIO por tu usuario de GitHub)
git remote add origin https://github.com/TU_USUARIO/proyecto-serverless-azure.git

# Crear y cambiar a rama main
git branch -M main

# Subir código a GitHub
git push -u origin main
```

---

## 🔑 PASO 3: Obtener Token de Azure Static Web Apps

Ejecuta este comando para obtener el token de deployment:

```bash
az staticwebapp secrets list \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --query 'properties.apiKey' \
  -o tsv
```

**⚠️ IMPORTANTE**: Guarda este token, lo necesitarás en el siguiente paso.

---

## 📝 PASO 4: Configurar Secreto en GitHub

1. Ve a tu repositorio en GitHub
2. Clic en **Settings** (pestaña del repositorio)
3. En el menú lateral izquierdo, clic en **Secrets and variables** → **Actions**
4. Clic en **New repository secret** (botón verde)
5. Configurar el secreto:
   - **Name**: `AZURE_STATIC_WEB_APPS_API_TOKEN`
   - **Secret**: [pega el token obtenido en el Paso 3]
6. Clic en **Add secret**

---

## ⚙️ PASO 5: Configurar GitHub Actions

El archivo `.github/workflows/azure-static-web-apps.yml` ya está creado en tu proyecto. Solo necesitas hacer commit y push:

```bash
# Agregar el archivo de workflow
git add .github/workflows/azure-static-web-apps.yml

# Hacer commit
git commit -m "Add GitHub Actions workflow for Azure Static Web Apps"

# Subir a GitHub
git push origin main
```

---

## 🔗 PASO 6: Vincular Repositorio a Azure Static Web Apps

Ejecuta este comando (sustituye `TU_USUARIO` por tu usuario de GitHub):

```bash
az staticwebapp update \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --source https://github.com/TU_USUARIO/proyecto-serverless-azure \
  --branch main
```

**📝 Nota**: Las configuraciones `app-location` y `output-location` se manejan automáticamente a través del archivo de GitHub Actions que ya está configurado.

---

## ✅ PASO 7: Verificar el Despliegue

### 7.1 Verificar GitHub Actions
1. Ve a tu repositorio en GitHub
2. Clic en la pestaña **Actions**
3. Deberías ver un workflow ejecutándose o completado
4. Clic en el workflow para ver los detalles

### 7.2 Verificar la URL personalizada
Una vez que el workflow termine exitosamente:

```bash
# Verificar que la URL personalizada funciona
curl -I https://crudapp-web-prod-ckp33m.azurestaticapps.net

# Debería retornar HTTP/2 200
```

### 7.3 Abrir la aplicación
La aplicación estará disponible en:
**https://crudapp-web-prod-ckp33m.azurestaticapps.net**

---

## 🎉 RESULTADO FINAL

Después de completar todos los pasos, tendrás:

✅ **URL personalizada activa**: `https://crudapp-web-prod-ckp33m.azurestaticapps.net`
✅ **Despliegue automático**: Cada push a `main` despliega automáticamente
✅ **Preview deployments**: Los pull requests crean deployments de preview
✅ **Historial de deployments**: Visible en GitHub Actions
✅ **Rollback fácil**: Desde Azure Portal o revertir commits

---

## 🔧 COMANDOS DE GESTIÓN

### Hacer cambios al frontend:
```bash
# Hacer cambios en el código
# Después:
git add .
git commit -m "Descripción de los cambios"
git push origin main
# El deployment se ejecuta automáticamente
```

### Ver logs del deployment:
- Ve a GitHub → Actions → Selecciona el workflow
- O en Azure Portal → Static Web Apps → Deployment history

### Deshabilitar auto-deployment temporalmente:
```bash
az staticwebapp update \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --source ""
```

---

## 🆘 TROUBLESHOOTING

### Si el deployment falla:
1. Verifica que el secreto `AZURE_STATIC_WEB_APPS_API_TOKEN` esté configurado
2. Revisa los logs en GitHub Actions
3. Verifica que las rutas en el workflow sean correctas

### Si la URL personalizada no funciona:
1. Espera 5-10 minutos después del deployment
2. Verifica que el repositorio esté correctamente vinculado
3. Revisa el workflow de GitHub Actions

### Para obtener ayuda:
```bash
# Ver estado de la Static Web App
az staticwebapp show \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih
```

---

*¡Siguiendo estos pasos tendrás tu aplicación desplegándose automáticamente en la URL personalizada!* 🚀
