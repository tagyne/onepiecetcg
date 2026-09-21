data "google_project" "current" {
  project_id = var.project_id
}

locals {
  workload_identity_principal = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.kubernetes_namespace}/sa/${var.api_service_account_name}"

  secret_ids = {
    database_url         = var.database_url_secret_id
    better_auth          = var.better_auth_secret_id
    google_client_id     = var.google_client_id_secret_id
    google_client_secret = var.google_client_secret_id
  }
}

resource "google_container_cluster" "this" {
  name                = var.cluster_name
  location            = var.region
  enable_autopilot    = true
  network             = "default"
  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  secret_sync_config {
    enabled = true
  }
}

resource "google_compute_global_address" "gateway" {
  name         = "onepiecetcg-gke-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_artifact_registry_repository_iam_member" "node_image_pull" {
  location   = var.artifact_registry_location
  repository = var.artifact_registry_repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "api_secret_accessor" {
  for_each = local.secret_ids

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = local.workload_identity_principal
}
