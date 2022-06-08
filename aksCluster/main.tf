resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rgName
  dns_prefix          = var.dnsPrefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"

    tags = {
      customer = var.customer
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    customer = var.customer
  }
}

variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "rgName" {
  type = string
}
variable "dnsPrefix" {
  type = string
}
variable "customer" {
  type = string
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}
output "client_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
}
output "client_key" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
}
output "cluster_ca_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}
output "principal_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
