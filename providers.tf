provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}
provider "helm" {
  kubernetes {
    load_config_file = false
    host = module.gke.k8s_endpoint
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = module.gke.gke_ca_certificate
  }
}
provider "kubernetes" {
  load_config_file = false
  host = module.gke.k8s_endpoint
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = module.gke.gke_ca_certificate
} 
# provider "azure" {
#   version = ">=2.0.0"
#   features {}
# }
# provider "aws" {
#   region = "eu-west"
# } 
