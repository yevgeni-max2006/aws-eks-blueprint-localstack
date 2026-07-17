
resource "helm_release" "redis" {
  name       = "redis"
  namespace  = kubernetes_namespace.ministack.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"

set = [
  {
    name  = "architecture"
    value = "standalone"
  },
  {
    name  = "auth.enabled"
    value = "false"
  },
  {
    name  = "master.persistence.size"
    value = "5Gi"
  }
 ]
}
