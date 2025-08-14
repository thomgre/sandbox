param naming object
param businessName string
param environment string
param location string = resourceGroup().location
param tags object

@secure()
param authDomain string

@secure()
param authAudience string

module appInsights './appinsights.bicep' = {
  name: 'AppInsightsDeployment'
  params: {
    environment: environment
    location: location
    logAnalyticsWorkspaceName: naming.logAnalyticsWorkspace.name
    applicationInsightsName: naming.applicationInsights.name
  }
}

module keyVault './keyvault.bicep' = {
  name: 'KeyVaultDeployment'
  params: {
    location: location
    environment: environment
    name: '${naming.keyVault.name}-thm'
    tags: tags
    diagnosticStorageAccountName: '${naming.storageAccountDiagnostic.name}thm'
    logsRetentionInDays: 7
    webAppPrincipalId: webApiAppService.outputs.webAppPrincipalId
  }
}

module storage './storage-account.bicep' = {
  name: 'StorageAccountDeployment'
  params: {
    location: location
    env: environment
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    name: '${naming.storageAccount.name}thm'
    tags: tags
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

//module roleAuthorization './storage-account-auth.bicep' = {
//  name: 'roleAuthorization'
//  params: {
//      principalId: webApiAppService.outputs.webAppPrincipalId
//      storageAccountName: storage.outputs.name
//      roleDefinition: 'Storage Blob Data Contributor'
//  }
//}
