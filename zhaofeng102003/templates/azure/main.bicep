param resourceBaseName string
param frontendHosting_storageName string = 'frontendstg${uniqueString(resourceBaseName)}'
param identity_managedIdentityName string = '${resourceBaseName}-managedIdentity'
param azureSql_admin string
@secure()
param azureSql_adminPassword string
param azureSql_serverName string = '${resourceBaseName}-sql-server'
param azureSql_databaseName string = '${resourceBaseName}-database'
param m365ClientId string
@secure()
param m365ClientSecret string
param m365TenantId string
param m365OauthAuthorityHost string
param function_serverfarmsName string = '${resourceBaseName}-function-serverfarms'
param function_webappName string = '${resourceBaseName}-function-webapp'
param function_storageName string = 'functionstg${uniqueString(resourceBaseName)}'
param simpleAuth_sku string = 'B1'
param simpleAuth_serverFarmsName string = '${resourceBaseName}-simpleAuth-serverfarms'
param simpleAuth_webAppName string = '${resourceBaseName}-simpleAuth-webapp'
param simpleAuth_packageUri string = 'https://github.com/OfficeDev/TeamsFx/releases/download/simpleauth@0.1.0/Microsoft.TeamsFx.SimpleAuth_0.1.0.zip'

var m365ApplicationIdUri = 'api://${frontendHostingProvision.outputs.domain}/${m365ClientId}'

param azureSql_databaseName2 string

module frontendHostingProvision './modules/frontendHostingProvision.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    frontendHostingStorageName: frontendHosting_storageName
  }
}
module userAssignedIdentityProvision './modules/userAssignedIdentityProvision.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    managedIdentityName: identity_managedIdentityName
  }
}
module azureSqlProvision './modules/azureSqlProvision.bicep' = {
  name: 'azureSqlProvision'
  params: {
    sqlServerName: azureSql_serverName
    sqlDatabaseName: azureSql_databaseName
    administratorLogin: azureSql_admin
    administratorLoginPassword: azureSql_adminPassword
    sqlDatabaseName2: azureSql_databaseName2
  }
}
module functionProvision './modules/functionProvision.bicep' = {
  name: 'functionProvision'
  params: {
    functionAppName: function_webappName
    functionServerfarmsName: function_serverfarmsName
    functionStorageName: function_storageName
    identityResourceId: userAssignedIdentityProvision.outputs.identityResourceId
  }
}
module functionConfiguration './modules/functionConfiguration.bicep' = {
  name: 'functionConfiguration'
  dependsOn: [
    functionProvision
  ]
  params: {
    functionAppName: function_webappName
    functionStorageName: function_storageName
    m365ClientId: m365ClientId
    m365ClientSecret: m365ClientSecret
    m365TenantId: m365TenantId
    m365ApplicationIdUri: m365ApplicationIdUri
    m365OauthAuthorityHost: m365OauthAuthorityHost
    frontendHostingStorageEndpoint: frontendHostingProvision.outputs.endpoint
    sqlDatabaseName: azureSqlProvision.outputs.databaseName
    sqlEndpoint: azureSqlProvision.outputs.sqlEndpoint
    identityClientId: userAssignedIdentityProvision.outputs.identityClientId
    sqlDatabaseName2: azureSqlProvision.outputs.databaseName2
  }
}
module simpleAuthProvision './modules/simpleAuthProvision.bicep' = {
  name: 'simpleAuthProvision'
  params: {
    simpleAuthServerFarmsName: simpleAuth_serverFarmsName
    simpleAuthWebAppName: simpleAuth_webAppName
    sku: simpleAuth_sku
  }
}
module simpleAuthConfiguration './modules/simpleAuthConfiguration.bicep' = {
  name: 'simpleAuthConfiguration'
  dependsOn: [
    simpleAuthProvision
  ]
  params: {
    simpleAuthWebAppName: simpleAuth_webAppName
    m365ClientId: m365ClientId
    m365ClientSecret: m365ClientSecret
    m365ApplicationIdUri: m365ApplicationIdUri
    frontendHostingStorageEndpoint: frontendHostingProvision.outputs.endpoint
    m365TenantId: m365TenantId
    oauthAuthorityHost: m365OauthAuthorityHost
    simpelAuthPackageUri: simpleAuth_packageUri
  }
}

output frontendHosting_storageResourceId string = frontendHostingProvision.outputs.resourceId
output frontendHosting_endpoint string = frontendHostingProvision.outputs.endpoint
output frontendHosting_domain string = frontendHostingProvision.outputs.domain
output identity_identityName string = userAssignedIdentityProvision.outputs.identityName
output identity_identityClientId string = userAssignedIdentityProvision.outputs.identityClientId
output identity_identityResourceId string = userAssignedIdentityProvision.outputs.identityResourceId
output azureSql_sqlResourceId string = azureSqlProvision.outputs.resourceId
output azureSql_sqlEndpoint string = azureSqlProvision.outputs.sqlEndpoint
output azureSql_databaseName string = azureSqlProvision.outputs.databaseName
output function_functionEndpoint string = functionProvision.outputs.functionEndpoint
output function_appResourceId string = functionProvision.outputs.functionAppResourceId
output simpleAuth_skuName string = simpleAuthProvision.outputs.skuName
output simpleAuth_endpoint string = simpleAuthProvision.outputs.endpoint
output simpleAuth_webAppName string = simpleAuthProvision.outputs.webAppName
output simpleAuth_appServicePlanName string = simpleAuthProvision.outputs.appServicePlanName

output azureSql_databaseName2 string = azureSqlProvision.outputs.databaseName2

