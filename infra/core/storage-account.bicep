// Storage Account module
// Creates storage account for AI Hub requirements

@description('Name of the storage account')
param name string

@description('Location for the storage account')
param location string = resourceGroup().location

@description('SKU of the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param sku string = 'Standard_LRS'

@description('Tags to apply to the resource')
param tags object = {}

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false // Disable public blob access per security best practices
    allowSharedKeyAccess: true // Enable for AI Hub requirement (will use RBAC for access control)
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
  }
}

@description('The name of the storage account')
output name string = storageAccount.name

@description('The resource ID of the storage account')
output id string = storageAccount.id

@description('The primary endpoints')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
