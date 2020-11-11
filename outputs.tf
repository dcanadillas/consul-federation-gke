
# output "gke_ca_certificate" {
#   value = base64decode(module.gke.ca_certificate)
# }
# output "consul_config" {
#   value = module.k8s[0].consul_yaml
# }
# output "k8s_endpoint" {
#   value = module.gke[0].k8s_endpoint
# }
output "consul_config" {
  value = module.k8s.consul_yaml
}
output "k8s_endpoint" {
  value = module.gke.k8s_endpoint
}
