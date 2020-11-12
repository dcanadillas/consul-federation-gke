output "consul_yaml" {
  value = "https://storage.cloud.google.com/${google_storage_bucket_object.consul-config.bucket}/${google_storage_bucket_object.consul-config.output_name}"
}
output "federation_secret" {
  value = data.kubernetes_secret.consul-federation.data
}