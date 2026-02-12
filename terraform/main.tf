terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "devops" {
  metadata {
    name = var.namespace

    labels = {
      name        = var.namespace
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_config_map" "devops_config" {
  metadata {
    name      = "devops-config"
    namespace = kubernetes_namespace.devops.metadata[0].name
  }

  data = {
    API_KEY     = var.api_key
    APP_NAME    = var.app_name
    APP_VERSION = var.app_version
  }
}

resource "kubernetes_secret" "devops_secrets" {
  metadata {
    name      = "devops-secrets"
    namespace = kubernetes_namespace.devops.metadata[0].name
  }

  type = "Opaque"

  data = {
    jwt-secret = base64encode(var.jwt_secret)
  }
}

resource "kubernetes_deployment" "devops_microservice" {
  metadata {
    name      = "devops-microservice"
    namespace = kubernetes_namespace.devops.metadata[0].name

    labels = {
      app     = "devops-microservice"
      version = "v1"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "devops-microservice"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app     = "devops-microservice"
          version = "v1"
        }
      }

      spec {
        container {
          name              = "devops-api"
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
            name           = "http"
            protocol       = "TCP"
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.devops_secrets.metadata[0].name
                key  = "jwt-secret"
              }
            }
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "devops_service" {
  metadata {
    name      = "devops-microservice-service"
    namespace = kubernetes_namespace.devops.metadata[0].name

    labels = {
      app = "devops-microservice"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "devops-microservice"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
      name        = "http"
    }

    session_affinity = "None"
  }
}

resource "kubernetes_ingress_v1" "devops_ingress" {
  metadata {
    name      = "devops-microservice-ingress"
    namespace = kubernetes_namespace.devops.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target"  = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.devops_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "devops_hpa" {
  metadata {
    name      = "devops-microservice-hpa"
    namespace = kubernetes_namespace.devops.metadata[0].name
  }

  spec {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.devops_microservice.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.cpu_target_percentage
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.memory_target_percentage
        }
      }
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Max"

        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }

      scale_up {
        stabilization_window_seconds = 0
        select_policy                = "Max"

        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 30
        }

        policy {
          type           = "Pods"
          value          = 2
          period_seconds = 30
        }
      }
    }
  }
}
