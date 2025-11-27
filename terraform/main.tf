resource "kubernetes_namespace" "catalogo" {
  metadata {
    name = var.namespace
  }
}

# Secret
resource "kubernetes_secret" "api_secret" {
  metadata {
    name      = "api-secret"
    namespace = kubernetes_namespace.catalogo.metadata[0].name
  }

  data = {
    jwt         = "supersecretojwt"
    db-user     = "root"
    db-password = "example"
    db-host     = "mysql"
    db-port     = "3306"
  }

  type = "Opaque"
}


# MySQL Deployment
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.catalogo.metadata[0].name
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "example"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "inventory_db"
          }

          port {
            container_port = 3306
          }
        }
      }
    }
  }
}

# MySQL Service
resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.catalogo.metadata[0].name
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }
  }
}

# API Deployment
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "product-api"
    namespace = kubernetes_namespace.catalogo.metadata[0].name
    labels = {
      app = "product-api"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "product-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "product-api"
        }
      }

      spec {
        container {
          name  = "product-api"
          image = var.api_image

          port {
            container_port = 3000
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_secret.metadata[0].name
                key  = "jwt"
              }
            }
          }

          env {
            name = "DB_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_secret.metadata[0].name
                key  = "db-host"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_secret.metadata[0].name
                key  = "db-user"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_secret.metadata[0].name
                key  = "db-password"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_secret.metadata[0].name
                key  = "db-port"
              }
            }
          }
        }
      }
    }
  }
}

# API Service
resource "kubernetes_service" "api" {
  metadata {
    name      = "product-api-service"
    namespace = kubernetes_namespace.catalogo.metadata[0].name
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "product-api"
    }

    port {
      port        = 80
      target_port = 3000
    }
  }
}
