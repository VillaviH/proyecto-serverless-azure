# 🔍 Diagnóstico del Error 404 en Azure Static Web Apps

## 🚨 **PROBLEMA ACTUAL:**
El frontend muestra "404: Not Found" en la URL personalizada.

## 🔍 **PASOS DE DIAGNÓSTICO:**

### 1. **Verificar URLs Disponibles**
```bash
# URL por defecto (que SÍ funciona)
curl -I https://happy-grass-00f8dff0f.2.azurestaticapps.net

# URL personalizada (que da 404)
curl -I https://crudapp-web-prod-ckp33m.azurestaticapps.net
```

### 2. **Verificar Estado del Repositorio GitHub**
```bash
# Ver información del repositorio vinculado
az staticwebapp show --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --query "{repositoryUrl:repositoryUrl, branch:branch, defaultHostname:defaultHostname}"
```

### 3. **Verificar GitHub Actions**
- Ve a: https://github.com/VillaviH/proyecto-serverless-azure/actions
- Verifica si hay workflows ejecutándose o fallando
- Revisa los logs de build

### 4. **Verificar Secreto de GitHub**
- Ve a: Settings > Secrets and variables > Actions
- Verifica que existe: `AZURE_STATIC_WEB_APPS_API_TOKEN`

---

## 🛠️ **POSIBLES CAUSAS Y SOLUCIONES:**

### **CAUSA 1: Repositorio no vinculado correctamente**
**Síntoma**: `repositoryUrl: null` en el comando de verificación

**Solución**:
```bash
az staticwebapp update \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --source https://github.com/VillaviH/proyecto-serverless-azure \
  --branch main
```

### **CAUSA 2: Secreto de GitHub no configurado**
**Síntoma**: Build falla en GitHub Actions con error de autenticación

**Soluciones**:
1. Obtener token:
```bash
az staticwebapp secrets list --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --query 'properties.apiKey' -o tsv
```

2. Configurar en GitHub:
- Settings > Secrets and variables > Actions
- New repository secret
- Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
- Value: [token del paso 1]

### **CAUSA 3: Build fallando por dependencias**
**Síntoma**: GitHub Actions falla en el step de build

**Solución**: El workflow ya fue corregido con:
- Setup de Node.js v18
- Instalación de dependencias: `npm ci --include=dev`
- Variables de entorno correctas

### **CAUSA 4: URL personalizada no activa**
**Síntoma**: Solo funciona la URL por defecto

**Explicación**: Esto es normal hasta que GitHub Actions complete exitosamente.

---

## ✅ **CHECKLIST PARA RESOLVER:**

- [ ] **Repositorio vinculado**: Ejecutar comando de vinculación
- [ ] **Token configurado**: Obtener y configurar secreto en GitHub
- [ ] **GitHub Actions funcionando**: Verificar que el build sea exitoso
- [ ] **Variables de entorno correctas**: En el workflow de GitHub Actions
- [ ] **Esperar propagación**: 5-10 minutos después de build exitoso

---

## 🎯 **COMANDOS RÁPIDOS:**

```bash
# 1. Vincular repositorio
az staticwebapp update \
  --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --source https://github.com/VillaviH/proyecto-serverless-azure \
  --branch main

# 2. Obtener token
az staticwebapp secrets list --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --query 'properties.apiKey' -o tsv

# 3. Verificar estado
az staticwebapp show --name crudapp-web-prod-ckp33m \
  --resource-group rg-crud-serverless-villavih \
  --query "{repositoryUrl:repositoryUrl, branch:branch}"

# 4. Probar URLs
curl -I https://crudapp-web-prod-ckp33m.azurestaticapps.net
curl -I https://happy-grass-00f8dff0f.2.azurestaticapps.net
```

---

## 📝 **ESTADO ACTUAL:**
- ✅ Repositorio GitHub creado y configurado
- ✅ Workflow de GitHub Actions corregido y pusheado
- ⏳ Esperando vinculación del repositorio
- ⏳ Esperando configuración del secreto
- ⏳ Esperando primer build exitoso

**PRÓXIMO PASO**: Configurar el secreto `AZURE_STATIC_WEB_APPS_API_TOKEN` en GitHub usando el token que se obtenga.
