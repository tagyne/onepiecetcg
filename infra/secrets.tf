resource "random_password" "better_auth" {
  length  = 64
  special = true
}

data "google_secret_manager_secret" "google_client_id" {
  secret_id = "oauth-google-client-id"
}

data "google_secret_manager_secret" "google_client_secret" {
  secret_id = "oauth-google-client-secret"
}

resource "google_secret_manager_secret" "better_auth" {
  secret_id = "better-auth-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "better_auth" {
  secret      = google_secret_manager_secret.better_auth.id
  secret_data = random_password.better_auth.result
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = local.database_url
}
