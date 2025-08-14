targetScope = 'subscription'

param location string
param applicationName string
param environment string
param tags object = {}

@secure()
param authDomain string

@secure()
param authAudience string

var defaultTags = union({
  applicationName: applicationName
  environment: environment
}, tags)

// Resource group which is the scope for the main deployment below
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${applicationName}-${environment}'
  location: location
  tags: defaultTags
}

// Naming module to configure the naming conventions for Azure
module naming './naming.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'NamingDeployment'
  params: {
    location: location
    suffix: [
      applicationName
      environment
      '**location**' // azure-naming location/region placeholder, it will be replaced with its abbreviation
    ]
    uniqueLength: 6
    uniqueSeed: rg.id
  }
}

// Main deployment has all the resources to be deployed for 
// a workload in the scope of the specific resource group
module main 'main.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'MainDeployment'
  params: {
    location: location
    businessName: applicationName
    naming: naming.outputs.names
    environment: environment
    tags: defaultTags
    authDomain: authDomain
    authAudience: authAudience
  }
}
