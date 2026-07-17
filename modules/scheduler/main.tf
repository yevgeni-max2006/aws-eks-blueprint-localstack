
resource "kubernetes_manifest" "velero_schedule" {
  #depends_on = [
  #  helm_release.velero
  #]

  manifest = {
    apiVersion = "velero.io/v1"
    kind = "Schedule"
    metadata = {

      name      = "resources-default"
      namespace = "velero"

    }
    spec = {
      schedule = "*/5 * * * *"
      template = {

        includedNamespaces = [
          "default"
        ]

        ttl = "168h"
        snapshotVolumes = false

      }
   }

  }
}
