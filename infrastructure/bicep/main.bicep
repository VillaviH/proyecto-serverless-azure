@description('Ubicación para todos los recursos')
param location string = resourceGroup().location

@description('Nombre base para todos los recursos')
param baseName string = 'crud-demo'

@description('Entorno (dev, test, prod)')
param environment string = 'dev'

@description('Username del administrador de SQL')
param sqlAdminUsername string = 'sqladmin'

@description('Password del administrador de SQL')
@secure()
param sqlAdminPassword string

@description('URL del repositorio de GitHub')
param repositoryUrl string = 'https://github.com/VillaviH/proyecto-serverless-azure'

@description('Rama del repositorio de GitHub')
param repositoryBranch string = 'main'

@description('Token de GitHub para deployment (opcional)')
@secure()
param repositoryToken string = ''

// Variables
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var functionAppName = '${baseName}-api-${environment}-${uniqueSuffix}'
var storageAccountName = replace('${baseName}${environment}${uniqueSuffix}', '-', '')
var appServicePlanName = '${baseName}-plan-${environment}-${uniqueSuffix}'
var sqlServerName = '${baseName}-sql-${environment}-${uniqueSuffix}'
var sqlDatabaseName = '${baseName}-db-${environment}'
var staticWebAppName = '${baseName}-web-${environment}-${uniqueSuffix}'
var applicationInsightsName = '${baseName}-ai-${environment}-${uniqueSuffix}'
var logAnalyticsWorkspaceName = '${baseName}-law-${environment}-${uniqueSuffix}'

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Storage Account para Azure Functions
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// App Service Plan para Azure Functions
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: false
  }
}

// Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Regla de firewall para permitir servicios de Azure
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  name: 'AllowAzureServices'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Azure SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB
  }
}

// Azure Functions App
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
          value: 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Database=${sqlDatabaseName};User ID=${sqlAdminUsername};Password=${sqlAdminPassword};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;'
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

// Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: repositoryBranch
    repositoryToken: !empty(repositoryToken) ? repositoryToken : null
    buildProperties: {
      appLocation: '/frontend'
      apiLocation: ''
      outputLocation: 'out'
    }
    provider: 'GitHub'
  }
}

// Outputs
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output staticWebAppName string = staticWebApp.name
output staticWebAppUrl string = 'https://${staticWebApp.properties.defaultHostname}'
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
