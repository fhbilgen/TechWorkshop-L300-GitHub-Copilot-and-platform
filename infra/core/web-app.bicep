// Web App (Linux Container) module
// Creates App Service configured to run Docker containers from ACR

@description('Name of the Web App')
param name string

@description('Location for the Web App')
param location string = resourceGroup().location

@description('App Service Plan ID')
param appServicePlanId string

@description('Container Registry login server')
param containerRegistryLoginServer string

@description('Container image name')
param containerImageName string = 'zava-storefront:latest'

@description('Application Insights connection string')
param applicationInsightsConnectionString string = ''

@description('Application Insights instrumentation key')
param applicationInsightsInstrumentationKey string = ''

@description('Service name for AZD tagging')
param serviceName string

@description('Tags to apply to the resource')
param tags object = {}

// Create Web App with Linux Container
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned' // Enable system-assigned managed identity for ACR pull
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true // Enforce HTTPS
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${containerImageName}'
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      acrUseManagedIdentityCreds: true // Use managed identity for ACR authentication
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'WEBSITES_PORT'
          value: '8080' // Default container port
        }
      ]
    }
  }
}

@description('The name of the Web App')
output name string = webApp.name

@description('The resource ID of the Web App')
output id string = webApp.id

@description('The default hostname of the Web App')
output defaultHostName string = webApp.properties.defaultHostName

@description('The principal ID of the system-assigned managed identity')
output principalId string = webApp.identity.principalId

@description('The Web App URL')
output uri string = 'https://${webApp.properties.defaultHostName}'
