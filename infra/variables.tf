variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "GCP region used by Cloud Run, Cloud SQL and Artifact Registry."
  type        = string
  default     = "europe-west1"
}

variable "gke_region" {
  description = "Regional location of the GKE Autopilot cluster."
  type        = string
  default     = "europe-west1"
}

variable "gke_cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  type        = string
  default     = "onepiecetcg-gke"
}

variable "gke_namespace" {
  description = "Namespace used by the One Piece TCG workloads on GKE."
  type        = string
  default     = "onepiecetcg"
}

variable "gke_api_service_account_name" {
  description = "Kubernetes ServiceAccount used by the API workload."
  type        = string
  default     = "onepiecetcg-api"
}

variable "web_domain" {
  description = "Frontend hostname managed in the OVH DNS zone."
  type        = string
  default     = "optcg.tagyne.fr"
}

variable "api_domain" {
  description = "API hostname managed in the OVH DNS zone."
  type        = string
  default     = "api-optcg.tagyne.fr"
}
