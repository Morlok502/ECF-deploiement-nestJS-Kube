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

        }
      }
    }
  }
}

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
