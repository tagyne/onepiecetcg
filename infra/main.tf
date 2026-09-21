locals {
  repository_root = abspath("${path.root}/..")
  image_registry  = "${var.region}-docker.pkg.dev/${var.project_id}/onepiecetcg"
  image_tag       = data.external.git.result.sha
  api_image       = "${local.image_registry}/api:${local.image_tag}"
  web_image       = "${local.image_registry}/web:${local.image_tag}"
  web_origin      = "https://${var.web_domain}"
  api_origin      = "https://${var.api_domain}"
}

data "external" "git" {
  program = [
    "bash",
    "-c",
    <<-EOT
      set -eu
      if [ -n "$(git status --porcelain)" ]; then
        echo "The repository must have no uncommitted changes before deployment." >&2
        exit 1
      fi
      printf '{"sha":"%s"}' "$(git rev-parse --verify HEAD)"
    EOT
  ]
}

resource "google_project_service" "required" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

module "gke" {
  source = "./modules/gke"

  project_id                 = var.project_id
  region                     = var.gke_region
  cluster_name               = var.gke_cluster_name
  kubernetes_namespace       = var.gke_namespace
  api_service_account_name   = var.gke_api_service_account_name
  database_url_secret_id     = google_secret_manager_secret.database_url.id
  better_auth_secret_id      = google_secret_manager_secret.better_auth.id
  google_client_id_secret_id = data.google_secret_manager_secret.google_client_id.id
  google_client_secret_id    = data.google_secret_manager_secret.google_client_secret.id

  depends_on = [google_project_service.required]
}

module "cloud_run" {
  source = "./modules/cloud-run"

  project_id                     = var.project_id
  region                         = var.region
  web_domain                     = var.web_domain
  api_domain                     = var.api_domain
  api_image                      = local.api_image
  web_image                      = local.web_image
  cloud_sql_connection_name      = google_sql_database_instance.postgres.connection_name
  ssl_certificate_id             = google_compute_managed_ssl_certificate.application.id
  google_client_id_secret_id     = data.google_secret_manager_secret.google_client_id.id
  google_client_secret_secret_id = data.google_secret_manager_secret.google_client_secret.id
  better_auth_secret_id          = google_secret_manager_secret.better_auth.id
  database_url_secret_id         = google_secret_manager_secret.database_url.id

  depends_on = [
    google_project_service.required,
    terraform_data.build_api_image,
    terraform_data.build_web_image,
    google_secret_manager_secret_version.better_auth,
    google_secret_manager_secret_version.database_url,
  ]
}
