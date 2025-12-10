// User-Assigned Managed Identity module
// Creates a managed identity for Azure resource authentication

@description('Name of the managed identity')
param name string

@description('Location for the managed identity')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

// Create User-Assigned Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

@description('The name of the managed identity')
output name string = managedIdentity.name

@description('The resource ID of the managed identity')
output id string = managedIdentity.id

@description('The principal ID of the managed identity')
output principalId string = managedIdentity.properties.principalId

@description('The client ID of the managed identity')
output clientId string = managedIdentity.properties.clientId
