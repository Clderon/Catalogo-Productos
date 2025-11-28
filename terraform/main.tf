# ========================
# NAMESPACE
# ========================
resource "kubernetes_namespace" "catalogo" {
  metadata {
    name = var.namespace
  }
}

# ========================
# SECRET (JWT + DB creds)
# ========================
resource "kubernetes_secret" "api_secret" {
  metadata {
    name      = "api-secret"
    namespace = var.namespace
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

# ========================
# CONFIGMAP init.sql
# ========================
resource "kubernetes_config_map" "mysql_init" {
  metadata {
    name      = "mysql-init"
    namespace = var.namespace
  }

  data = {
    "init.sql" = file("${path.module}/../database/init.sql")
  }
}

# ========================
# MYSQL DEPLOYMENT
# ========================
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "mysql" }
    }

    template {
      metadata {
        labels = { app = "mysql" }
      }

      spec {

        volume {
          name = "mysql-initdb"
          config_map {
            name = kubernetes_config_map.mysql_init.metadata[0].name
          }
        }

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

          volume_mount {
            name       = "mysql-initdb"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }
      }
    }
  }
}

# ========================
# MYSQL SERVICE
# ========================
resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
  }

  spec {
    selector = { app = "mysql" }

    port {
      port        = 3306
      target_port = 3306
    }
  }
}

# ========================
# API DEPLOYMENT
# ========================
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "product-api"
    namespace = var.namespace
    labels = {
      app = "product-api"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "product-api" }
    }

    template {
      metadata {
        labels = { app = "product-api" }
      }

      spec {
        container {
          name  = "product-api"
          image = var.api_image

          image_pull_policy = "Never"
          
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

# ========================
# API SERVICE (LoadBalancer)
# ========================
resource "kubernetes_service" "api" {
  metadata {
    name      = "product-api-service"
    namespace = var.namespace
  }

  spec {
    type = "LoadBalancer"

    selector = { app = "product-api" }

    port {
      port        = 80
      target_port = 3000
      
    }
  }
}
