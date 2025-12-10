// Key Vault module
// Creates Key Vault for secrets management

@description('Name of the Key Vault')
param name string

@description('Location for the Key Vault')
param location string = resourceGroup().location

@description('Tenant ID')
param tenantId string = tenant().tenantId

@description('Tags to apply to the resource')
param tags object = {}

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enableRbacAuthorization: true // Use RBAC instead of access policies
    enableSoftDelete: true
    enablePurgeProtection: true // DO NOT disable purge protection per security best practices
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
  }
}

@description('The name of the Key Vault')
output name string = keyVault.name

@description('The resource ID of the Key Vault')
output id string = keyVault.id

@description('The URI of the Key Vault')
output uri string = keyVault.properties.vaultUri
