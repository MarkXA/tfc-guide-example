resource "kubernetes_manifest" "deployment_azure_vote_back" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "azure-vote-back"
      "namespace" = "default"
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
      "namespace" = "default"
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
      "name" = "azure-vote-front"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
        },
      ]
      "selector" = {
        "app" = "azure-vote-front"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_azure_vote_front" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "azure-vote-front"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "azure-vote-front"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "azure-vote-front"
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
              "name" = "azure-vote-front"
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
    "apiVersion" = "networking.k8s.io/v1"
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
                "path" = "/"
                "pathType" = "Prefix"
                "backend" = {
                  "service" = { 
                    "name" = "azure-vote-front"
                    "port" = {
                      "number" = 80
                    }
                  }
                }
              }
            ]
          }
        },
      ]
    }
  }
}
