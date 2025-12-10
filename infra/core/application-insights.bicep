// Application Insights module
// Creates Application Insights for application monitoring

@description('Name of the Application Insights resource')
param name string

@description('Location for Application Insights')
param location string = resourceGroup().location

@description('Log Analytics Workspace ID')
param workspaceId string

@description('Tags to apply to the resource')
param tags object = {}

// Create Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The name of Application Insights')
output name string = applicationInsights.name

@description('The resource ID of Application Insights')
output id string = applicationInsights.id

@description('The instrumentation key')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string')
output connectionString string = applicationInsights.properties.ConnectionString
