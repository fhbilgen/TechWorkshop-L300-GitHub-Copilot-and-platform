// Azure AI Foundry (AI Hub) module
// Creates AI Hub for GPT-4 and Phi model access

@description('Name of the AI Hub')
param name string

@description('Location for the AI Hub')
param location string = resourceGroup().location

@description('Storage Account ID')
param storageAccountId string

@description('Key Vault ID')
param keyVaultId string

@description('Application Insights ID')
param applicationInsightsId string

@description('Container Registry ID')
param containerRegistryId string

@description('Tags to apply to the resource')
param tags object = {}

// Create AI Hub (Microsoft Foundry) with SystemAssigned identity
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    publicNetworkAccess: 'Enabled'
  }
}

@description('The name of the AI Hub')
output name string = aiHub.name

@description('The resource ID of the AI Hub')
output id string = aiHub.id
