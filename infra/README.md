# Azure Infrastructure for ZavaStorefront

This folder contains the Infrastructure as Code (IaC) for deploying the ZavaStorefront application to Azure using Bicep and Azure Developer CLI (azd).

## Architecture Overview

The infrastructure provisions a complete containerized web application environment with AI capabilities:

- **Azure Container Registry (ACR)** - Stores Docker container images
- **Linux App Service** - Hosts the containerized .NET 6.0 web application
- **App Service Plan** - Provides compute resources (B1 SKU for dev)
- **Application Insights** - Application performance monitoring
- **Log Analytics Workspace** - Centralized logging
- **Azure AI Hub (Microsoft Foundry)** - Provides GPT-4 and Phi model access
- **Storage Account** - Required by AI Hub
- **Key Vault** - Secrets management for AI Hub
- **User-Assigned Managed Identity** - Required by AZD
- **RBAC Role Assignments** - AcrPull role for Web App to pull images from ACR

## File Structure

```
infra/
├── main.bicep                      # Main orchestration template
├── main.parameters.json            # Parameters file for AZD
└── core/                           # Modular Bicep templates
    ├── container-registry.bicep    # ACR configuration
    ├── app-service-plan.bicep      # App Service Plan
    ├── web-app.bicep               # Web App for Containers
    ├── application-insights.bicep  # Application Insights
    ├── log-analytics.bicep         # Log Analytics Workspace
    ├── ai-hub.bicep                # Azure AI Hub (Foundry)
    ├── storage-account.bicep       # Storage Account
    ├── key-vault.bicep             # Key Vault
    ├── managed-identity.bicep      # User-Assigned Identity
    └── role-assignment.bicep       # RBAC role assignments
```

## Security Features

✅ **RBAC Authentication** - No passwords for ACR access  
✅ **Managed Identity** - System-assigned identity for Web App  
✅ **HTTPS Only** - Enforced secure connections  
✅ **Key Access Disabled** - Storage Account uses RBAC only  
✅ **Public Blob Access Disabled** - Storage security  
✅ **Purge Protection Enabled** - Key Vault data protection  
✅ **Anonymous Pull Disabled** - ACR security  
✅ **TLS 1.2 Minimum** - Modern encryption standards

## Deployment

### Prerequisites

- Azure CLI (`az --version`)
- Azure Developer CLI (`azd version`)
- Azure subscription with appropriate permissions
- Region availability for all services (default: westus3)

### Deploy with AZD

```powershell
# Initialize AZD environment (first time only)
azd init

# Login to Azure
azd auth login

# Provision infrastructure and deploy application
azd up
```

### Preview Changes

```powershell
# Preview what will be deployed
azd provision --preview
```

### Deploy Only Infrastructure

```powershell
# Provision infrastructure without deploying the app
azd provision
```

### Deploy Only Application

```powershell
# Deploy application code without provisioning
azd deploy
```

## Parameters

The following parameters can be configured in `main.parameters.json` or via environment variables:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environmentName` | Environment name for resource naming | `${AZURE_ENV_NAME}` |
| `location` | Azure region | `${AZURE_LOCATION}` |
| `webServiceName` | Service name for the web app | `web` |
| `containerImageName` | Container image name | `zava-storefront:latest` |
| `containerRegistrySku` | ACR SKU | `Basic` |
| `appServicePlanSku` | App Service Plan SKU | `B1` |
| `storageAccountSku` | Storage Account SKU | `Standard_LRS` |

## Resource Naming Convention

Resources follow the AZD naming convention:
- Format: `az{prefix}{uniqueToken}`
- Unique token: Generated from subscription ID, resource group ID, location, and environment name
- Example: `azacr3x7k2m9` (Container Registry)

## Outputs

After deployment, the following outputs are available:

- `RESOURCE_GROUP_ID` - Resource group identifier
- `WEB_APP_URL` - Web application URL
- `WEB_APP_NAME` - Web App resource name
- `CONTAINER_REGISTRY_LOGIN_SERVER` - ACR login server
- `CONTAINER_REGISTRY_NAME` - ACR resource name
- `APPLICATION_INSIGHTS_CONNECTION_STRING` - App Insights connection
- `AI_HUB_NAME` - AI Hub resource name

## Cost Optimization

Development SKUs are used by default:
- **Container Registry**: Basic (pay-per-use)
- **App Service Plan**: B1 (1.75 GB RAM, 1 vCPU)
- **Storage Account**: Standard_LRS (locally redundant)
- **Log Analytics**: Pay-per-GB ingestion

Estimated monthly cost: $15-30 for development usage

## Troubleshooting

### Bicep Validation

```powershell
# Validate Bicep template
az bicep build --file infra/main.bicep
```

### View Deployment Logs

```powershell
# View application logs
azd monitor --logs
```

### Clean Up Resources

```powershell
# Delete all provisioned resources
azd down
```

## AZD Compliance

This infrastructure follows Azure Developer CLI requirements:

✅ User-Assigned Managed Identity exists  
✅ Resource Group has `azd-env-name` tag  
✅ Web App has `azd-service-name` tag  
✅ Parameters use `${{AZURE_ENV_NAME}}` and `${{AZURE_LOCATION}}` format  
✅ Outputs include `RESOURCE_GROUP_ID`  
✅ App Service Site Extension installed  
✅ Storage Account has local auth disabled  
✅ Storage Account has public blob access disabled

## Next Steps

1. Review and customize parameters in `main.parameters.json`
2. Run `azd up` to deploy the infrastructure
3. Configure AI Hub with GPT-4 and Phi models in Azure Portal
4. Set up GitHub Actions for CI/CD (see `.github/workflows/`)
5. Monitor application with Application Insights

## Support

For issues or questions:
- Review Azure Activity Log in the Azure Portal
- Check Application Insights for runtime issues
- Use `azd monitor` for application logs
- Refer to [Azure Developer CLI documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
