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
  value       = try(module.cloud_run[0].load_balancer_ip, null)
}

output "gke_cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  value       = try(module.gke[0].cluster_name, null)
}

output "gke_cluster_region" {
  description = "Regional location of the GKE Autopilot cluster."
  value       = try(module.gke[0].region, null)
}

output "gke_workload_pool" {
  description = "Workload Identity Federation pool used by the GKE cluster."
  value       = try(module.gke[0].workload_pool, null)
}

output "gke_gateway_ip" {
  description = "Global static IP reserved for the GKE Gateway load balancer."
  value       = try(module.gke[0].gateway_ip, null)
}
