variable "project_id" {
  description = "Google Cloud project ID containing the GKE cluster and secrets."
  type        = string
}

variable "region" {
  description = "Regional location of the GKE Autopilot cluster."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Namespace used by the application workloads."
  type        = string
}

variable "api_service_account_name" {
  description = "Kubernetes ServiceAccount used by the API workload."
  type        = string
}

variable "database_url_secret_id" {
  description = "Secret Manager resource ID for the database URL."
  type        = string
}

variable "better_auth_secret_id" {
  description = "Secret Manager resource ID for the Better Auth secret."
  type        = string
}

variable "google_client_id_secret_id" {
  description = "Secret Manager resource ID for the Google OAuth client ID."
  type        = string
}

variable "google_client_secret_id" {
  description = "Secret Manager resource ID for the Google OAuth client secret."
  type        = string
}
