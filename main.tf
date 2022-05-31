resource "azurerm_resource_group" "rg" {
  name     = "mxa-rasptest"
  location = var.location

  tags = {
    customer = "allsop"
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
    customer = "allsop"
  }
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "raspdb"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"

  tags = {
    customer = "allsop"
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
    customer = "allsop"
  }
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "mxa-raspbus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  tags = {
    customer = "allsop"
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
    customer = "allsop"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "mxaraspacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"

  tags = {
    customer = "allsop"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "mxa-raspaks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "mxarasp"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    customer = "allsop"
  }
}

resource "azurerm_role_assignment" "aksacrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
