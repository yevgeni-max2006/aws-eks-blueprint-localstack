
resource "kubernetes_namespace" "ministack" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "ministack" {
  metadata {
    name      = "ministack-s3-data"
    namespace = kubernetes_namespace.ministack.metadata[0].name
  }

  spec {
    access_modes = [
      "ReadWriteOnce"
    ]

    storage_class_name = var.storage_class
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}


resource "kubernetes_deployment" "ministack" {
  metadata {
    name      = "ministack"
    namespace = kubernetes_namespace.ministack.metadata[0].name

    labels = {
      app = "ministack"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ministack"
      }
    }

    template {
      metadata {
        labels = {
          app = "ministack"
        }
      }

      spec {

        container {
          name  = "ministack"
          image = var.image

          port {
            container_port = 4566
          }

          env {
            name  = "GATEWAY_PORT"
            value = "4566"
          }

          env {
            name  = "LOG_LEVEL"
            value = "INFO"
          }

          env {
            name  = "S3_PERSIST"
            value = "1"
          }

          env {
            name  = "REDIS_HOST"
            value = "redis-master"
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }

          env {
            name  = "RDS_BASE_PORT"
            value = "15432"
          }

          env {
            name  = "ELASTICACHE_BASE_PORT"
            value = "16379"
          }

          volume_mount {
            name       = "s3-data"
            mount_path = "/tmp/ministack-data/s3"
          }

          readiness_probe {
            http_get {
              path = "/_ministack/health"
              port = 4566
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/_ministack/health"
              port = 4566
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
        volume {
          name = "s3-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ministack.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "ministack" {
  metadata {
    name      = "ministack"
    namespace = kubernetes_namespace.ministack.metadata[0].name
  }
  spec {
    selector = {
      app = "ministack"
    }
    port {
      port        = 4566
      target_port = 4566
    }
    type = "ClusterIP"
  }
}
