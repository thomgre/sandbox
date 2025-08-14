param location string
param env string
param name string
param tags object = {}

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_LRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param skuName string = 'Standard_LRS'
param keyVaultName string

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: toLower(replace(name, '-', ''))
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  tags: union(tags, {
    displayName: name
  })
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: env != 'prd'
    allowBlobPublicAccess: env != 'prd'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storage
  properties: {
    changeFeed: {
      enabled: true
      retentionInDays: 7
    }
    cors: {
      corsRules: [
        {
          allowedHeaders: [
            '*'
          ]
          allowedMethods: [
            'GET'
            'HEAD'
            'OPTIONS'
          ]
          allowedOrigins: [
            '*'
          ]
          exposedHeaders: [
            'content-length'
            'content-type'
          ]
          maxAgeInSeconds: 200
        }
      ]
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 365
      enabled: true
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 90
      enabled: true
    }
    isVersioningEnabled: true
    lastAccessTimeTrackingPolicy: {
      blobType: [
        'blockBlob'
      ]
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
    }
    restorePolicy: {
      days: 60
      enabled: true
    }
  }
}

var secretName = 'blobStorageConnectionString'
module storeConnectionStringToKeyVault './keyVault-secret.bicep' = {
  name: 'keyVault-${secretName}'
  params: {
    keyVaultName: keyVaultName
    isEnabled: true
    //DefaultEndpointsProtocol=https;AccountName=storagesample;AccountKey=<account-key>
    secretValue: 'DefaultEndpointsProtocol=https;AccountName=${blobService.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    contentType: 'text/plain'
    secretName: secretName
  }
}

output id string = storage.id
output name string = storage.name
output apiVersion string = storage.apiVersion
output primaryEndpoints object = storage.properties.primaryEndpoints
output ConnectionStringSecretUri string = storeConnectionStringToKeyVault.outputs.secretUri
