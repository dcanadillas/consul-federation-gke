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
  count = 2
  dns_zone = var.dns_zone
  gcp_project = var.gcp_project
  gcp_region = var.gcp_region
  gcp_zone = var.gcp_zone
  gcs_bucket = "dcanadillas-se"
  gke_cluster = "${var.gke_cluster}-${count.index}"
  # gke_cluster = "${var.gke_cluster}-${count.index}"
  default_gke = var.default_gke
  owner = var.owner
  service_account = var.service_account
}


module "k8s" {
  source = "./modules/kubernetes"
  depends_on = [ module.gke ]
  providers = {
    helm = helm.primary
    kubernetes = kubernetes.primary
  }
  cluster_endpoint = module.gke.0.k8s_endpoint
  cluster_namespace = "consul"
  ca_certificate = module.gke.0.gke_ca_certificate
  location = var.gcp_zone
  gcp_region = var.gcp_region
  gcp_project = var.gcp_project
  cluster_name = var.gke_cluster
  config_bucket = var.gcs_bucket
  nodes = var.consul_nodes
  gcp_service_account = data.google_service_account.owner_project
  dns_zone = var.dns_zone
  consul_license = var.consul_license
}

module "k8s-sec" {
  source = "./modules/kubernetes"
  depends_on = [ 
    module.gke,
    module.k8s
  ]
  providers = {
    helm = helm.secondary
    kubernetes = kubernetes.secondary
  }
  cluster_endpoint = module.gke.1.k8s_endpoint
  cluster_namespace = "consul"
  ca_certificate = module.gke.1.gke_ca_certificate
  location = var.gcp_zone
  gcp_region = var.gcp_region
  gcp_project = var.gcp_project
  cluster_name = var.gke_cluster
  config_bucket = var.gcs_bucket
  nodes = var.consul_nodes
  gcp_service_account = data.google_service_account.owner_project
  dns_zone = var.dns_zone
  consul_license = var.consul_license
}
