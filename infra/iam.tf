resource "google_service_account" "cloud_run" {
  account_id   = "onepiecetcg-runtime"
  display_name = "One Piece TCG Cloud Run runtime"
}

resource "google_project_iam_member" "cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_secret_access" {
  for_each = {
    google_client_id     = data.google_secret_manager_secret.google_client_id.id
    google_client_secret = data.google_secret_manager_secret.google_client_secret.id
    better_auth          = google_secret_manager_secret.better_auth.id
    database_url         = google_secret_manager_secret.database_url.id
  }

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}
