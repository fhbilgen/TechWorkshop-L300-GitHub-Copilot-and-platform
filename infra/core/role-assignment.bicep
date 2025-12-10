// Role Assignment module
// Assigns Azure RBAC roles to principals on resources

@description('Principal ID to assign the role to')
param principalId string

@description('Role Definition ID (GUID)')
param roleDefinitionId string

@description('Principal type')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string = 'ServicePrincipal'

@description('Resource ID to assign the role on')
param resourceId string

// Get the resource to assign the role on
resource targetResource 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: last(split(resourceId, '/'))
}

// Create role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: targetResource
  name: guid(targetResource.id, principalId, roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

@description('The name of the role assignment')
output name string = roleAssignment.name

@description('The resource ID of the role assignment')
output id string = roleAssignment.id
