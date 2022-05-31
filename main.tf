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
