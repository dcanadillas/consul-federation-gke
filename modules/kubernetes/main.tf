
# data "google_container_cluster" "gke_cluster" {
#     name = var.cluster_name
#     location = var.location
# }
# We create some local vars to make it easier later
# locals {
#   cluster_ca = data.google_container_cluster.gke_cluster.master_auth
#   hostk8s = data.google_container_cluster.gke_cluster.endpoint
# }
# provider "google" {
#   project = var.gcp_project
#   region = var.gcp_region
# }

# provider "helm" {
#   kubernetes {
#     load_config_file = false

#     # We use this conditional to be sure that when the cluster is created there is no dependencies issues
#     # host = data.google_container_cluster.gke_cluster.endpoint
#     # host = local.hostk8s!= null ? local.hostk8s : var.cluster_endpoint
#     host = var.cluster_endpoint

#     # username = "${var.username}"
#     # password = "${var.password}"
#     token = data.google_client_config.default.access_token

#     # client_certificate = "${base64decode(var.client_certificate)}"
#     # client_key = "${base64decode(var.client_key)}"

#     # We use this conditional to be sure that when the cluster is created there is no dependencies issues
#     # cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate )
#     # cluster_ca_certificate = local.cluster_ca != null ? base64decode(local.cluster_ca.0.cluster_ca_certificate) : base64decode(var.ca_certificate)
#     # cluster_ca_certificate = base64decode(var.ca_certificate)
#     cluster_ca_certificate = var.ca_certificate

#   }
# }
# provider "kubernetes" {
#     load_config_file = false

#     # host = data.google_container_cluster.gke_cluster.endpoint
#     # host = local.hostk8s!= null ? local.hostk8s : var.cluster_endpoint
#     host = var.cluster_endpoint
#     # insecure = true

#     # username = "${var.username}"
#     # password = "${var.password}"
#     token = data.google_client_config.default.access_token

#     # client_certificate = "${base64decode(var.client_certificate)}"
#     # client_key = "${base64decode(var.client_key)}"

#     # We use this conditional to be sure that when the cluster is created there is no dependencies issues
#     # cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate )
#     # cluster_ca_certificate = local.cluster_ca != null ? base64decode(local.cluster_ca.0.cluster_ca_certificate) : base64decode(var.ca_certificate)
#     # cluster_ca_certificate = base64decode(var.ca_certificate)
#     cluster_ca_certificate = var.ca_certificate
# }

# The Helm provider creates the namespace, but if we want to create it manually would be with following lines
resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.cluster_namespace
  }
}
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "ingress"
  }
}

# Creating dynamically a hostname list to use later on template
data "null_data_source" "hostnames" {
  count = var.nodes
  inputs = {
      hostnames = "consul-${count.index}"
  }
}
locals {
  hostnames = data.null_data_source.hostnames.*.inputs.hostnames
}

# Let's create a secret with the json credentials
resource "google_service_account_key" "gcp_sa_key" {
  service_account_id = var.gcp_service_account.name
}
resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name = "gcp-creds"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.gcp_sa_key.private_key)
  }
}
resource "kubernetes_secret" "consul-license" {
  metadata {
    name = "consul-ent-license"
    namespace = kubernetes_namespace.consul.metadata.0.name
  }
  data = {
    "key" = var.consul_license
  }
}


# Because we are executing remotely using TFC/TFE we want to save our templates in a Cloud bucket
resource "google_storage_bucket_object" "consul-config" {
  name   = "${var.cluster_name}-${formatdate("YYMMDD_HHmm",timestamp())}.yml"
  content = templatefile("${path.root}/templates/consul-values-dc.yaml",{
            # hostname = var.hostname,
            # hosts = local.hostnames,
            # http = var.tls == "enabled" ? "https" : "http",
            # disable_tls = var.tls == "enabled" ? false : true,
            # tls = var.tls
            })
  bucket = var.config_bucket
}

resource "google_storage_bucket_object" "nginx-config" {
  name   = "${var.cluster_name}-${formatdate("YYMMDD_HHmm",timestamp())}.yml"
  content = templatefile("${path.root}/templates/nginx.yaml.tpl",{
            vault_namespace = kubernetes_namespace.consul.metadata.0.name,
            })
  bucket = var.config_bucket
}

## I you want to create the template files locally uncomment the following lines (This is not working with remote execution in TFE)
# resource "local_file" "foo" {
#     content     = templatefile("${path.root}/templates/consul_values.yaml",{
#           hostname = var.hostname,
#           vault_version = var.vault_version
#           })
#     filename = "${path.root}/templates/vault.yaml"
# }


# We need to create a sleep to let the ingress Load Balancer be assigned, so we can get the Ingress data
# resource "time_sleep" "wait_60_seconds" {
#   depends_on = [
#     helm_release.consul,
#     helm_release.nginx,
#   ]

#   create_duration = "60s"
# }


# resource "google_dns_record_set" "consul" {
#   count = var.dns_zone != null ? 1 : 0
#   name = "${var.hostname}."
#   type = "A"
#   ttl  = 300

#   managed_zone = var.dns_zone

#   rrdatas = [data.kubernetes_ingress.vault.load_balancer_ingress.0.ip]
# }