terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aksCluster.host
  client_certificate     = module.aksCluster.client_certificate
  client_key             = module.aksCluster.client_key
  cluster_ca_certificate = module.aksCluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.aksCluster.host
    client_certificate     = module.aksCluster.client_certificate
    client_key             = module.aksCluster.client_key
    cluster_ca_certificate = module.aksCluster.cluster_ca_certificate
  }
}
