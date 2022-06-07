data "azurerm_kubernetes_cluster" "aksdata" {
  name                = "mxa-raspaks"
  resource_group_name = azurerm_resource_group.rg.name
}
