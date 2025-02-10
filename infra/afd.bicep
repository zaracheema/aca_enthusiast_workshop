// Front Door Resources
// CLI Details can be found here:
// https://learn.microsoft.com/en-us/azure/container-apps/how-to-integrate-with-azure-front-door

param frontDoorProfileName string
param containerAppEnvId string
param containerAppFqdns array

//param containerApps array
//var containerAppFqdns = [for i in range(0, length(containerApps)): containerApps[i].properties.configuration.ingress.fqdn]


param appendix string
param location string

var frontDoorOriginGroupName = 'fdog-${appendix}'
var frontDoorOriginNames = [for i in range(0, length(containerAppFqdns)): 'fdon-${appendix}-${i}']
var frontDoorRouteName = 'fdrn-${appendix}'
var frontDoorEndpointName = 'afd-${appendix}'


resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}


resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}


resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: null
  }
}

// create one origin per container app fqdn
resource frontDoorOrigins 'Microsoft.Cdn/profiles/originGroups/origins@2024-09-01' = [for i in range(0, length(containerAppFqdns)): {
  name: frontDoorOriginNames[i]
  parent: frontDoorOriginGroup
  properties: {
    hostName: containerAppFqdns[i]
    originHostHeader: containerAppFqdns[i]
    priority: 1
    weight: 500
    sharedPrivateLinkResource: {
      groupId: 'managedEnvironments'
      privateLink: {
        id: containerAppEnvId
      }
      privateLinkLocation: location
      requestMessage: 'AFD Private Link Request'
      status: 'Approved'
    }
  }
}]


resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
  dependsOn: [
    frontDoorOrigins
  ]
}

// TODO: spit out the needed outputs

