@description('Ubicación para todos los recursos')
param location string = resourceGroup().location

@description('Nombre base para todos los recursos')
param baseName string = 'crudapp'

@description('Entorno (dev, test, prod)')
param environment string = 'prod'

// Variables (usando los mismos nombres que ya existen)
var uniqueSuffix = 'ckp33m' // Usando el mismo sufijo que ya se generó
var functionAppName = '${baseName}-api-${environment}-${uniqueSuffix}'
var storageAccountName = '${baseName}${environment}${uniqueSuffix}'
var appServicePlanName = '${baseName}-plan-${environment}-${uniqueSuffix}'
var applicationInsightsName = '${baseName}-ai-${environment}-${uniqueSuffix}'

// Referencias a recursos existentes
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: appServicePlanName
}

// Application Insights (falta crear)
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', '${baseName}-law-${environment}-${uniqueSuffix}')
  }
}

// Azure Functions App (falta crear)
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionAppName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'SqlConnectionString'
          value: 'Server=tcp:${baseName}-sql-${environment}-${uniqueSuffix}.${az.environment().suffixes.sqlServerHostname},1433;Database=${baseName}-db-${environment};User ID=sqladmin;Password=MySecureP@ssw0rd2025!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;'
        }
      ]
      cors: {
        allowedOrigins: ['*']
        supportCredentials: false
      }
      netFrameworkVersion: 'v8.0'
    }
  }
}

// Outputs
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output staticWebAppName string = '${baseName}-web-${environment}-${uniqueSuffix}'
output staticWebAppUrl string = 'https://${baseName}-web-${environment}-${uniqueSuffix}.azurestaticapps.net'
