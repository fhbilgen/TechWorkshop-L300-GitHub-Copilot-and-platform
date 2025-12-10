// App Service Plan module
// Creates Linux App Service Plan for hosting containerized applications

@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
])
param sku string = 'B1'

@description('Tags to apply to the resource')
param tags object = {}

// Create Linux App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
}

@description('The name of the App Service Plan')
output name string = appServicePlan.name

@description('The resource ID of the App Service Plan')
output id string = appServicePlan.id
