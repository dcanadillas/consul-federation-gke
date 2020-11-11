data "google_container_cluster" "primary_gke" {
  depends_on = [ module.gke ]
  name     = module.gke.0.cluster_name
  location = var.gcp_zone
}

data "google_container_cluster" "secondary_gke" {
  depends_on = [ module.gke ]
  name     = module.gke.1.cluster_name
  location = var.gcp_zone
}

provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  alias = "primary"
  kubernetes {
    load_config_file = false
    # host = module.gke.k8s_endpoint
    token = data.google_client_config.current.access_token
    # cluster_ca_certificate = module.gke.gke_ca_certificate
    host = data.google_container_cluster.primary_gke.endpoint
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary_gke.master_auth.0.cluster_ca_certificate)
  }
}
provider "kubernetes" {
  alias = "primary"
  load_config_file = false
  # host = module.gke.k8s_endpoint
  token = data.google_client_config.current.access_token
  # cluster_ca_certificate = module.gke.gke_ca_certificate
  host = data.google_container_cluster.primary_gke.endpoint
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary_gke.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  alias = "secondary"
  kubernetes {
    load_config_file = false
    # host = module.gke.k8s_endpoint
    token = data.google_client_config.current.access_token
    # cluster_ca_certificate = module.gke.gke_ca_certificate
    host = data.google_container_cluster.secondary_gke.endpoint
    cluster_ca_certificate = base64decode(data.google_container_cluster.secondary_gke.master_auth.0.cluster_ca_certificate)
  }
}
provider "kubernetes" {
  alias = "secondary"
  load_config_file = false
  # host = module.gke.k8s_endpoint
  token = data.google_client_config.current.access_token
  # cluster_ca_certificate = module.gke.gke_ca_certificate
  host = data.google_container_cluster.secondary_gke.endpoint
  cluster_ca_certificate = base64decode(data.google_container_cluster.secondary_gke.master_auth.0.cluster_ca_certificate)
} 


