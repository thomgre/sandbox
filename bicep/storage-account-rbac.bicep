param storageAccountName string
param principalId string

@allowed([
  'Storage Blob Data Contributor'
  'Storage Blob Data Reader'
])
param roleDefinition string

var roles = {
  // See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for these mappings and more.
  'Storage Blob Data Contributor': '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage Blob Data Reader': '/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}
var roleDefinitionId = roles[roleDefinition]

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

// Allow webapp to access storage account using managed identity
resource roleAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Generate a unique but deterministic resource name
  name: guid('storage-rbac', storageAccount.id, resourceGroup().id, principalId, roleDefinitionId)
  scope: storageAccount
  properties: {
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: roleDefinitionId
  }
}
