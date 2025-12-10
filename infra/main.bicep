// Main Bicep template for ZavaStorefront Azure Infrastructure
// Provisions all resources for containerized .NET application with AI capabilities

targetScope = 'resourceGroup'

// Required AZD parameters
@minLength(1)
@maxLength(64)
@description('Name of the environment for resource naming')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Service configuration
@description('Service name for the web application')
param webServiceName string = 'web'

@description('Container image name')
param containerImageName string = 'zava-storefront:latest'

// SKU parameters
@description('Container Registry SKU')
@allowed(['Basic', 'Standard', 'Premium'])
param containerRegistrySku string = 'Basic'

@description('App Service Plan SKU')
@allowed(['B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v2', 'P2v2', 'P3v2'])
param appServicePlanSku string = 'B1'

@description('Storage Account SKU')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', 'Premium_LRS'])
param storageAccountSku string = 'Standard_LRS'

// Generate unique resource token
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)
var tags = {
  'azd-env-name': environmentName
  environment: 'dev'
  project: 'zavaStorefront'
}

// Resource naming following AZD conventions (prefix + resource token)
var acrName = 'azacr${resourceToken}'
var appServicePlanName = 'azasp${resourceToken}'
var webAppName = 'azapp${resourceToken}'
var logAnalyticsName = 'azlog${resourceToken}'
var appInsightsName = 'azai${resourceToken}'
var managedIdentityName = 'azid${resourceToken}'
var storageAccountName = 'azst${resourceToken}'
var keyVaultName = 'azkv${resourceToken}'
var aiHubName = 'azaih${resourceToken}'

// Deploy User-Assigned Managed Identity (required by AZD)
module managedIdentity 'core/managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    name: managedIdentityName
    location: location
    tags: tags
  }
}

// Deploy Log Analytics Workspace
module logAnalytics 'core/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Deploy Application Insights
module applicationInsights 'core/application-insights.bicep' = {
  name: 'application-insights-deployment'
  params: {
    name: appInsightsName
    location: location
    workspaceId: logAnalytics.outputs.id
    tags: tags
  }
}

// Deploy Container Registry
module containerRegistry 'core/container-registry.bicep' = {
  name: 'container-registry-deployment'
  params: {
    name: acrName
    location: location
    sku: containerRegistrySku
    tags: tags
  }
}

// Deploy App Service Plan
module appServicePlan 'core/app-service-plan.bicep' = {
  name: 'app-service-plan-deployment'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
    tags: tags
  }
}

// Deploy Web App
module webApp 'core/web-app.bicep' = {
  name: 'web-app-deployment'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryLoginServer: containerRegistry.outputs.loginServer
    containerImageName: containerImageName
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    serviceName: webServiceName
    tags: tags
  }
}

// Assign AcrPull role to Web App managed identity on Container Registry
module acrPullRoleAssignment 'core/role-assignment.bicep' = {
  name: 'acr-pull-role-assignment'
  params: {
    principalId: webApp.outputs.principalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role ID
    principalType: 'ServicePrincipal'
    resourceId: containerRegistry.outputs.id
  }
}

// Deploy Storage Account for AI Hub
module storageAccount 'core/storage-account.bicep' = {
  name: 'storage-account-deployment'
  params: {
    name: storageAccountName
    location: location
    sku: storageAccountSku
    tags: tags
  }
}

// Deploy Key Vault for AI Hub
module keyVault 'core/key-vault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    name: keyVaultName
    location: location
    tags: tags
  }
}

// Deploy AI Hub (Microsoft Foundry) for GPT-4 and Phi models
module aiHub 'core/ai-hub.bicep' = {
  name: 'ai-hub-deployment'
  params: {
    name: aiHubName
    location: location
    storageAccountId: storageAccount.outputs.id
    keyVaultId: keyVault.outputs.id
    applicationInsightsId: applicationInsights.outputs.id
    containerRegistryId: containerRegistry.outputs.id
    tags: tags
  }
}

// Required AZD output
@description('Resource Group ID for AZD')
output RESOURCE_GROUP_ID string = resourceGroup().id

// Service outputs
@description('Web App URL')
output WEB_APP_URL string = webApp.outputs.uri

@description('Web App name')
output WEB_APP_NAME string = webApp.outputs.name

@description('Container Registry login server')
output CONTAINER_REGISTRY_LOGIN_SERVER string = containerRegistry.outputs.loginServer

@description('Container Registry name')
output CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

@description('Application Insights connection string')
output APPLICATION_INSIGHTS_CONNECTION_STRING string = applicationInsights.outputs.connectionString

@description('AI Hub name')
output AI_HUB_NAME string = aiHub.outputs.name

@description('Environment name')
output ENVIRONMENT_NAME string = environmentName
