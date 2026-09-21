resource "google_service_account" "runtime" {
  account_id   = "onepiecetcg-runtime"
  display_name = "One Piece TCG Cloud Run runtime"
}

resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each = {
    google_client_id     = var.google_client_id_secret_id
    google_client_secret = var.google_client_secret_secret_id
    better_auth          = var.better_auth_secret_id
    database_url         = var.database_url_secret_id
  }

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}
