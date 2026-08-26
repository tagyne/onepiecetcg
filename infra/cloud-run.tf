resource "google_cloud_run_v2_service" "api" {
  name                = "onepiecetcg-api"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account                  = google_service_account.cloud_run.email
    timeout                          = "3600s"
    max_instance_request_concurrency = 100
    session_affinity                 = true

    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres.connection_name]
      }
    }

    containers {
      image = local.api_image
      ports {
        container_port = 3000
      }
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "API_PORT"
        value = "3000"
      }
      env {
        name  = "WEB_ORIGIN"
        value = local.web_origin
      }
      env {
        name  = "BETTER_AUTH_URL"
        value = local.api_origin
      }
      env {
        name  = "SESSION_COOKIE_DOMAIN"
        value = ".tagyne.fr"
      }
      env {
        name  = "SESSION_COOKIE_SECURE"
        value = "true"
      }
      env {
        name  = "SESSION_COOKIE_SAME_SITE"
        value = "lax"
      }
      env {
        name  = "AUTH_ANONYMOUS_ENABLED"
        value = "false"
      }

      env {
        name = "GOOGLE_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.google_client_id.id
            version = "latest"
          }
        }
      }
      env {
        name = "GOOGLE_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.google_client_secret.id
            version = "latest"
          }
        }
      }
      env {
        name = "BETTER_AUTH_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.better_auth.id
            version = "latest"
          }
        }
      }
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    terraform_data.build_api_image,
    google_secret_manager_secret_version.better_auth,
    google_secret_manager_secret_version.database_url,
  ]
}

resource "google_cloud_run_v2_service" "web" {
  name                = "onepiecetcg-web"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run.email
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    containers {
      image = local.web_image
      ports {
        container_port = 3001
      }
      env {
        name  = "NUXT_PUBLIC_API_BASE"
        value = local.api_origin
      }
      env {
        name  = "NUXT_PUBLIC_COLYSEUS_ENDPOINT"
        value = "wss://${var.api_domain}"
      }
      env {
        name  = "NUXT_API_INTERNAL_BASE"
        value = local.api_origin
      }
      env {
        name  = "NITRO_HOST"
        value = "0.0.0.0"
      }
      env {
        name  = "NITRO_PORT"
        value = "3001"
      }
    }
  }

  depends_on = [terraform_data.build_web_image]
}

resource "google_cloud_run_v2_service_iam_member" "api_public" {
  name     = google_cloud_run_v2_service.api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "web_public" {
  name     = google_cloud_run_v2_service.web.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
