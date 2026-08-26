resource "random_password" "database" {
  length  = 32
  special = false
}

resource "google_sql_database_instance" "postgres" {
  name             = "onepiecetcg-postgres"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier              = "db-perf-optimized-N-2"
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "application" {
  name     = "onepiecetcg"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "application" {
  name     = "onepiecetcg"
  instance = google_sql_database_instance.postgres.name
  password = random_password.database.result
}

locals {
  database_url = "postgresql://${google_sql_user.application.name}:${random_password.database.result}@/${google_sql_database.application.name}?host=/cloudsql/${google_sql_database_instance.postgres.connection_name}"
}
