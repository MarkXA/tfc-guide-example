resource "azurerm_resource_group" "rg" {
  name     = "mxa-rasptest"
  location = var.location

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "mxa-raspsqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "thePassword123!"

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "raspdb"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_redis_cache" "redis" {
  name                = "mxa-raspredis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"

  redis_configuration {
  }

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "mxa-raspbusns"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "workspace-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "mxa-raspinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.loganalytics.id
  application_type    = "web"

  tags = {
    customer = var.CUSTOMER
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "mxaraspacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"

  tags = {
    customer = var.CUSTOMER
  }
}

module "aksCluster" {
  source = "./aksCluster"

  name      = "mxa-raspaks"
  location  = azurerm_resource_group.rg.location
  rgName    = azurerm_resource_group.rg.name
  dnsPrefix = "mxarasp"
  customer  = var.CUSTOMER
}

resource "azurerm_role_assignment" "aksacrpull" {
  principal_id                     = module.aksCluster.principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "helm_release" "nginx_ingress" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}
