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
  value       = module.cloud_run.load_balancer_ip
}

output "gke_cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  value       = module.gke.cluster_name
}

output "gke_cluster_region" {
  description = "Regional location of the GKE Autopilot cluster."
  value       = module.gke.region
}

output "gke_workload_pool" {
  description = "Workload Identity Federation pool used by the GKE cluster."
  value       = module.gke.workload_pool
}

output "gke_gateway_ip" {
  description = "Global static IP reserved for the GKE Gateway load balancer."
  value       = module.gke.gateway_ip
}
