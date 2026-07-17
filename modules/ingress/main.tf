resource "kubernetes_ingress_v1" "kong_ingress" {
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace

    annotations = {
      "konghq.com/strip-path" = "true"
    }

    labels = {
      app = var.name
    }
  }

  spec {
    ingress_class_name = "kong"

    tls {
      hosts = [
        var.host
      ]

      secret_name = var.tls_secret_name
    }

    rule {
      host = var.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.name

              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}
