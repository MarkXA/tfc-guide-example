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
  name                = "mxa-raspbus"
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
    customer = var.CUSTOMER
  }
}

resource "azurerm_role_assignment" "aksacrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

resource "kubernetes_manifest" "deployment_azure_vote_back" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "azure-vote-back"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "azure-vote-back"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "azure-vote-back"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "ALLOW_EMPTY_PASSWORD"
                  "value" = "yes"
                },
              ]
              "image" = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"
              "name" = "azure-vote-back"
              "ports" = [
                {
                  "containerPort" = 6379
                  "name" = "redis"
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "250m"
                  "memory" = "256Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "128Mi"
                }
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_azure_vote_back" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "azure-vote-back"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 6379
        },
      ]
      "selector" = {
        "app" = "azure-vote-back"
      }
    }
  }
}

resource "kubernetes_manifest" "service_azure_vote_front" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = var.FRONTNAME
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
        },
      ]
      "selector" = {
        "app" = var.FRONTNAME
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_azure_vote_front" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = var.FRONTNAME
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = var.FRONTNAME
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = var.FRONTNAME
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "REDIS"
                  "value" = "azure-vote-back"
                },
              ]
              "image" = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"
              "name" = var.FRONTNAME
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "250m"
                  "memory" = "256Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "128Mi"
                }
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "ingress_azure_vote" {
  manifest = {
    "apiVersion" = "extensions/v1beta1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "azure/application-gateway"
      }
      "name" = "azure-vote"
      "namespace" = "default"
    }
    "spec" = {
      "rules" = [
        {
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "serviceName" = var.FRONTNAME
                  "servicePort" = 80
                }
                "path" = "/"
              },
            ]
          }
        },
      ]
    }
  }
}

# resource "kubernetes_manifest" "deployment-back" {
#   manifest = yamldecode(file("azureVoteDeploymentBack.yaml"))
# }
# resource "kubernetes_manifest" "deployment-front" {
#   manifest = yamldecode(templatefile("azureVoteDeploymentFront.yaml", { FRONTNAME = var.FRONTNAME }))
# }
# resource "kubernetes_manifest" "service-back" {
#   manifest = yamldecode(file("azureVoteServiceBack.yaml"))
# }
# resource "kubernetes_manifest" "service-front" {
#   manifest = yamldecode(templatefile("azureVoteServiceFront.yaml", { FRONTNAME = var.FRONTNAME }))
# }
