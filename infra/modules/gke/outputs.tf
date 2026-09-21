output "cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  value       = google_container_cluster.this.name
}

output "region" {
  description = "Regional location of the GKE Autopilot cluster."
  value       = google_container_cluster.this.location
}

output "workload_pool" {
  description = "Workload Identity Federation pool used by the GKE cluster."
  value       = "${var.project_id}.svc.id.goog"
}

output "gateway_ip" {
  description = "Global static IP reserved for the GKE Gateway load balancer."
  value       = google_compute_global_address.gateway.address
}
