variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Region used by Cloud Run and the serverless load balancer."
  type        = string
}

variable "web_domain" {
  description = "Frontend hostname."
  type        = string
}

variable "api_domain" {
  description = "API hostname."
  type        = string
}

variable "api_image" {
  description = "API container image."
  type        = string
}

variable "web_image" {
  description = "Web container image."
  type        = string
}

variable "cloud_sql_connection_name" {
  description = "Cloud SQL connection name mounted by Cloud Run."
  type        = string
}

variable "ssl_certificate_id" {
  description = "Shared global SSL certificate attached to the Cloud Run load balancer."
  type        = string
}

variable "google_client_id_secret_id" {
  description = "Secret Manager resource ID for the Google OAuth client ID."
  type        = string
}

variable "google_client_secret_secret_id" {
  description = "Secret Manager resource ID for the Google OAuth client secret."
  type        = string
}

variable "better_auth_secret_id" {
  description = "Secret Manager resource ID for the Better Auth secret."
  type        = string
}

variable "database_url_secret_id" {
  description = "Secret Manager resource ID for the database URL."
  type        = string
}
