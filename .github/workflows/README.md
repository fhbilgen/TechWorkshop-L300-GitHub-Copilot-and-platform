# GitHub Actions Deployment Setup

This repository includes a GitHub Actions workflow to automatically build and deploy the ZavaStorefront .NET application as a container to Azure App Service.

## Prerequisites

- Azure resources provisioned (App Service, Container Registry, Resource Group)
- GitHub repository with appropriate permissions

## Required GitHub Secrets

Add the following secret to your repository (`Settings` → `Secrets and variables` → `Actions` → `New repository secret`):

### `AZURE_CREDENTIALS`

Azure service principal credentials in JSON format:

```json
{
  "clientId": "<your-service-principal-client-id>",
  "clientSecret": "<your-service-principal-client-secret>",
  "subscriptionId": "<your-azure-subscription-id>",
  "tenantId": "<your-azure-tenant-id>"
}
```

**To create the service principal:**

```bash
az ad sp create-for-rbac \
  --name "github-actions-zavastore" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name> \
  --sdk-auth
```

Copy the entire JSON output and paste it as the secret value.

## Required GitHub Variables

Add the following variables to your repository (`Settings` → `Secrets and variables` → `Actions` → `Variables` tab → `New repository variable`):

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `ACR_LOGIN_SERVER` | Azure Container Registry login server | `azacrelqbcbez5bgya.azurecr.io` |
| `ACR_NAME` | Azure Container Registry name | `azacrelqbcbez5bgya` |
| `APP_SERVICE_NAME` | Azure App Service name | `azappelqbcbez5bgya` |
| `RESOURCE_GROUP` | Azure Resource Group name | `twl301-rg` |

**To get these values from your deployed infrastructure:**

```bash
# Get all values at once
azd env get-values

# Or individually
az webapp list --resource-group <your-rg> --query "[0].name" -o tsv
az acr list --resource-group <your-rg> --query "[0].{name:name, loginServer:loginServer}"
```

## Workflow Trigger

The workflow runs automatically on:
- Push to `main` or `dev` branches
- Manual trigger via GitHub Actions UI (`Actions` → `Build and Deploy to Azure App Service` → `Run workflow`)

## What the Workflow Does

1. **Checkout code** - Gets the latest code from the repository
2. **Azure Login** - Authenticates to Azure using service principal
3. **Build image in ACR** - Builds Docker image using cloud build (no local Docker needed)
4. **Deploy to App Service** - Updates App Service to use the new container image
5. **Restart App Service** - Restarts the app to apply changes

## Verify Deployment

After the workflow completes successfully:

1. Check the Actions tab for workflow status
2. Visit your App Service URL (available in Azure Portal or via `az webapp show`)
3. Monitor logs: `az webapp log tail --name <app-name> --resource-group <rg-name>`
