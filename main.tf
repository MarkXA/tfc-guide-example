resource "azurerm_resource_group" "rg" {
  name     = "mxa-rasptest"
  location = var.location

  tags = {
    customer = "allsop"
  }
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = "mxa-raspsqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  tags = {
    customer = "allsop"
  }
}

resource "azurerm_sql_database" "sqlserver" {
  name                = "raspdb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlserver.name

  tags = {
    customer = "allsop"
  }
}