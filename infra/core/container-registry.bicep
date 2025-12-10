// Azure Container Registry module
// Creates ACR for storing container images with RBAC authentication (no admin password)

@description('Name of the container registry')
param name string

@description('Location for the container registry')
param location string = resourceGroup().location

@description('SKU of the container registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Tags to apply to the resource')
param tags object = {}

// Create Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false // Use RBAC instead of admin credentials
    anonymousPullEnabled: false // Disable anonymous pull access per security best practices
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: sku == 'Premium' ? 'Enabled' : 'Disabled'
  }
}

@description('The name of the container registry')
output name string = containerRegistry.name

@description('The resource ID of the container registry')
output id string = containerRegistry.id

@description('The login server of the container registry')
output loginServer string = containerRegistry.properties.loginServer
