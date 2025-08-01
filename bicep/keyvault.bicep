param location string
param environment string
param name string
param tags object = {}
param diagnosticStorageAccountName string
param webAppPrincipalId string

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 0

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false      // Using Access Policies model
    accessPolicies: [
      {
        objectId: webAppPrincipalId
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'get'
            'list'
          ] 
          secrets: [
            'get'
            'list'
          ] 
        }
      }
    ]
    enabledForDeployment: true          // VMs can retrieve certificates
    enabledForTemplateDeployment: true  // ARM can retrieve values
    enablePurgeProtection: environment == 'prd' ? true : null  // Not allowing to purge key vault or its objects after deletion (null instead of false as workaround, see: https://github.com/Azure/azure-rest-api-specs/issues/18106)
    enableSoftDelete: true
    //softDeleteRetentionInDays: 90     // Fails when keyvault already exists
    createMode: 'default'               // Creating or updating the key vault (not recovering)
  }
}

resource sto 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: diagnosticStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: {
    displayName: 'Key Vault ${name} diagnostics storage account'
  }
}

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: 'service'
  properties: {
    storageAccountId: sto.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}

output keyVaultName string = keyVault.name
