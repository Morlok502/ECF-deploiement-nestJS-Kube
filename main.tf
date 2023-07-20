########## Secrets ##########

resource "kubernetes_secret" "postgres_auth" {
  metadata {
    name = "postgres-auth"
  }

  data = {
    username      = var.username
    password      = var.password
    database_name = var.database_name
  }

  type = "kubernetes.io/postgres-auth"
}


########## Deployment ##########

resource "kubernetes_deployment" "hello-world-nest-js" {
  metadata {
    name = "terraform-deploy-kube"
    labels = {
      app_to_deploy = "ECF-Hello-world-nestJS"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app_to_deploy = "ECF-Hello-world-nestJS"
      }
    }

    template {
      metadata {
        labels = {
          app_to_deploy = "ECF-Hello-world-nestJS"
        }
      }

      spec {
        container {
          image = "211758855362.dkr.ecr.eu-west-3.amazonaws.com/studi-ecf:latest"
          name  = "hello-world-nest-js"

          liveness_probe {
            tcp_socket {
              port = 3000
            }

            failure_threshold     = 3
            initial_delay_seconds = 3
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 2
          }

          readiness_probe {
            tcp_socket {
              port = 3000
            }

            failure_threshold     = 1
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 2
          }

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          env {
            name  = "POSTGRES_USER"
            value = kubernetes_secret.postgres_auth.data.username
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = kubernetes_secret.postgres_auth.data.password
          }
          env {
            name  = "POSTGRES_DATABASE"
            value = kubernetes_secret.postgres_auth.data.database_name
          }
        }
      }
    }
  }
}

########## Service ##########

resource "kubernetes_service" "hello-world-nest-js" {
  metadata {
    name = "terraform-deploy-kube"
  }
  spec {
    selector = {
      app_to_deploy = "ECF-Hello-world-nestJS"
    }
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
