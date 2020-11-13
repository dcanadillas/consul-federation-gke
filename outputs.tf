# output "consul_config" {
#   value = module.k8s.consul_yaml
# }
output "gke_endpoints" {
  value = module.gke.*.k8s_endpoint
}
output "caCert" {
  value = module.k8s.federation_secret.caCert
}
output "consul_values_dc1" {
  value = module.k8s.consul_yaml
}
output "consul_values_dc2" {
  value = var.create_federation ? module.k8s-sec.0.consul_yaml : null
}
