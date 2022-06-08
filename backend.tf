terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "allsoptfstate"
    container_name       = "tfstate"
    key                  = var.STATEFILE
  }
}
