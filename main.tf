terraform {
  required_version = ">= 0.13"
  # backend "remote" {
  # }
}

# Collect client config for GCP
data "google_client_config" "current" {
}
data "google_service_account" "owner_project" {
  account_id = var.service_account
}
module "gke" {
  # source  = "app.terraform.io/hc-dcanadillas/gke/tf"
  source  = "github.com/dcanadillas/dcanadillas-tf-gke"
  # version = "0.1.0"
  # count = 2
  dns_zone = var.dns_zone
  gcp_project = var.gcp_project
  gcp_region = var.gcp_region
  gcp_zone = var.gcp_zone
  gcs_bucket = "dcanadillas-se"
  gke_cluster = var.gke_cluster
  # gke_cluster = "${var.gke_cluster}-${count.index}"
  default_gke = var.default_gke
  owner = "dcanadillas"
  service_account = var.service_account
}


module "k8s" {
  source = "./modules/kubernetes"
  depends_on = [ module.gke ]
  # count = 2
  # token = data.google_client_config.current.access_token
  cluster_endpoint = module.gke.k8s_endpoint
  # cluster_endpoint = module.gke["${count.index}"].k8s_endpoint
  # cluster_endpoint = "https://104.155.31.46"
  # client_certificate = module.gke.client_certificate
  cluster_namespace = "consul"
  # client_key = module.gke.client_key
  ca_certificate = module.gke.gke_ca_certificate
  # ca_certificate = module.gke["${count.index}"].gke_ca_certificate
  location = var.gcp_zone
  gcp_region = var.gcp_region
  gcp_project = var.gcp_project
  cluster_name = var.gke_cluster
  # cluster_name = "${var.gke_cluster}-${count.index}"
  config_bucket = var.gcs_bucket
  # hostname = var.hostname
  nodes = var.consul_nodes
  gcp_service_account = data.google_service_account.owner_project
  # tls = var.tls
  dns_zone = var.dns_zone
  consul_license = var.consul_license
}

