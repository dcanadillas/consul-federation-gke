# output "consul_config" {
#   value = module.k8s.consul_yaml
# }
output "gke_endpoints" {
  value = module.gke.*.k8s_endpoint
}
output "gke_hosts" {
  value = [
    local.primary_host,
    local.secondary_host
  ]
}
output "Federation_CA_cert" {
  value = module.k8s.federation_secret.caCert
}
output "consul_values_dc1" {
  value = module.k8s.consul_yaml
}
output "consul_values_dc2" {
  value = var.create_federation ? module.k8s-sec.0.consul_yaml : null
}
# output "consul_ui" {
#   value = [
#     module.k8s.consul_ui,
#     var.create_federation ? module.k8s-sec.0.consul_ui : null
#   ]
# }
output "GKE_CA_certs" {
  value = [
    module.gke[0].gke_ca_certificate,
    module.gke[1].gke_ca_certificate
  ]
}
