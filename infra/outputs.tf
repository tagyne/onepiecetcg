output "image_tag" {
  description = "Git commit SHA used for the Docker images."
  value       = local.image_tag
}

output "web_url" {
  value = local.web_origin
}

output "api_url" {
  value = local.api_origin
}

output "load_balancer_ip" {
  description = "IP to configure in the OVH DNS zone."
  value       = google_compute_global_address.application.address
}
