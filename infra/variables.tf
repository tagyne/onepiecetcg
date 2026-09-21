variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "GCP region used by Cloud Run, Cloud SQL and Artifact Registry."
  type        = string
  default     = "europe-west9"
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
