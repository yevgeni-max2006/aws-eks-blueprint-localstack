
resource "kubernetes_secret" "minio_console_tls" {
  metadata {
    name      = "minio-console-tls"
    namespace = "default"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("${path.module}/tls.crt")
    "tls.key" = file("${path.module}/tls.key")
  }
}

resource "kubernetes_manifest" "minio_gateway" {
  depends_on = [
    kubernetes_secret.minio_console_tls
  ]
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "minio"
      namespace = "default"
    }

    spec = {
      gatewayClassName = "kong"

      listeners = [
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          hostname = "minio-console.pay-plus.cloud"

          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind = "Secret"
                name = "minio-console-tls"
              }
            ]
          }
          allowedRoutes = {
            namespaces = {
              from = "Same"
            }
          }
        }
      ]
    }
  }
}


resource "kubernetes_manifest" "minio_console_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "minio-console"
      namespace = "default"
    }
    
    spec = {
      parentRefs = [
        {
          name        = "minio-console"
          sectionName = "https"
        }
      ]
      hostnames = [
        "s3-bucket.appflex.io"
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = "minio-console"
              port = 9090
            }
          ]
        }
      ]
    }
  }
}
