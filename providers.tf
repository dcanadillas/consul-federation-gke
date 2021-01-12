data "google_container_cluster" "primary_gke" {
  depends_on = [ module.gke ]
  name     = module.gke.0.cluster_name
  location = var.gcp_zone[0]
}

data "google_container_cluster" "secondary_gke" {
  count = var.create_federation ? 1 : 0
  depends_on = [ module.gke ]
  name     = module.gke.1.cluster_name
  location = var.gcp_zone[1]
}

locals {
  primary_host = data.google_container_cluster.primary_gke.endpoint
  primary_cert = base64decode(data.google_container_cluster.primary_gke.master_auth.0.cluster_ca_certificate)
  secondary_host = var.create_federation ? data.google_container_cluster.secondary_gke.0.endpoint : ""
  secondary_cert = var.create_federation ? base64decode(data.google_container_cluster.secondary_gke.0.master_auth.0.cluster_ca_certificate) : ""
}

provider "google" {
  project = var.gcp_project
  # region = var.gcp_region
}
provider "helm" {
  alias = "primary"
  kubernetes {
    # load_config_file = false
    token = data.google_client_config.current.access_token
    host = local.primary_host
    cluster_ca_certificate = local.primary_cert
  }
}
provider "kubernetes" {
  alias = "primary"
  load_config_file = false
  token = data.google_client_config.current.access_token
  host = local.primary_host
  cluster_ca_certificate = local.primary_cert
}

provider "helm" {
  alias = "secondary"
  kubernetes {
    # load_config_file = false
    token = data.google_client_config.current.access_token
    host = local.secondary_host
    cluster_ca_certificate = local.secondary_cert
  }
}
provider "kubernetes" {
  alias = "secondary"
  load_config_file = false
  token = data.google_client_config.current.access_token
  host = local.secondary_host
  cluster_ca_certificate = local.secondary_cert
} 


