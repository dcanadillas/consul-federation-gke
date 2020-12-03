resource "helm_release" "consul" {
  # depends_on = [
  #     kubernetes_secret.google-application-credentials,
  # ]
  name = "consul"
  # Depending on deprecation of data.helm_repository
  # repository = "${data.helm_repository.vault.metadata[0].name}"
  repository = "https://helm.releases.hashicorp.com"
  chart  = "consul"
  create_namespace = false
  namespace = kubernetes_namespace.consul.metadata.0.name
  force_update = false
  version = var.chart_version

  values = [
      google_storage_bucket_object.consul-config.content
  ]

  wait = false
}

data "kubernetes_secret" "consul-federation" {
  depends_on = [ helm_release.consul ]
  metadata {
    name = "consul-federation"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }
}

