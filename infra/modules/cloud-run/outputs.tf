output "load_balancer_ip" {
  description = "Global IP of the Cloud Run load balancer."
  value       = google_compute_global_address.application.address
}
