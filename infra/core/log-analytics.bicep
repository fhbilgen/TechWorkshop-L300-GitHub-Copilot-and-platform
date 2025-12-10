// Log Analytics Workspace module
// Creates workspace for centralized logging

@description('Name of the Log Analytics Workspace')
param name string

@description('Location for the workspace')
param location string = resourceGroup().location

@description('SKU of the workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('Retention period in days')
param retentionInDays int = 30

@description('Tags to apply to the resource')
param tags object = {}

// Create Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The name of the Log Analytics Workspace')
output name string = logAnalyticsWorkspace.name

@description('The resource ID of the Log Analytics Workspace')
output id string = logAnalyticsWorkspace.id

@description('The customer ID (workspace ID)')
output customerId string = logAnalyticsWorkspace.properties.customerId
