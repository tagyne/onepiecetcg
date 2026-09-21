moved {
  from = google_cloud_run_v2_service.api
  to   = module.cloud_run.google_cloud_run_v2_service.api
}

moved {
  from = google_cloud_run_v2_service.web
  to   = module.cloud_run.google_cloud_run_v2_service.web
}

moved {
  from = google_cloud_run_v2_service_iam_member.api_public
  to   = module.cloud_run.google_cloud_run_v2_service_iam_member.api_public
}

moved {
  from = google_cloud_run_v2_service_iam_member.web_public
  to   = module.cloud_run.google_cloud_run_v2_service_iam_member.web_public
}

moved {
  from = google_service_account.cloud_run
  to   = module.cloud_run.google_service_account.runtime
}

moved {
  from = google_project_iam_member.cloud_run_sql_client
  to   = module.cloud_run.google_project_iam_member.sql_client
}

moved {
  from = google_secret_manager_secret_iam_member.cloud_run_secret_access["google_client_id"]
  to   = module.cloud_run.google_secret_manager_secret_iam_member.secret_access["google_client_id"]
}

moved {
  from = google_secret_manager_secret_iam_member.cloud_run_secret_access["google_client_secret"]
  to   = module.cloud_run.google_secret_manager_secret_iam_member.secret_access["google_client_secret"]
}

moved {
  from = google_secret_manager_secret_iam_member.cloud_run_secret_access["better_auth"]
  to   = module.cloud_run.google_secret_manager_secret_iam_member.secret_access["better_auth"]
}

moved {
  from = google_secret_manager_secret_iam_member.cloud_run_secret_access["database_url"]
  to   = module.cloud_run.google_secret_manager_secret_iam_member.secret_access["database_url"]
}

moved {
  from = google_compute_global_address.application
  to   = module.cloud_run.google_compute_global_address.application
}

moved {
  from = google_compute_region_network_endpoint_group.web
  to   = module.cloud_run.google_compute_region_network_endpoint_group.web
}

moved {
  from = google_compute_region_network_endpoint_group.api
  to   = module.cloud_run.google_compute_region_network_endpoint_group.api
}

moved {
  from = google_compute_backend_service.web
  to   = module.cloud_run.google_compute_backend_service.web
}

moved {
  from = google_compute_backend_service.api
  to   = module.cloud_run.google_compute_backend_service.api
}

moved {
  from = google_compute_url_map.https
  to   = module.cloud_run.google_compute_url_map.https
}

moved {
  from = google_compute_target_https_proxy.application
  to   = module.cloud_run.google_compute_target_https_proxy.application
}

moved {
  from = google_compute_global_forwarding_rule.https
  to   = module.cloud_run.google_compute_global_forwarding_rule.https
}

moved {
  from = google_compute_url_map.http_redirect
  to   = module.cloud_run.google_compute_url_map.http_redirect
}

moved {
  from = google_compute_target_http_proxy.redirect
  to   = module.cloud_run.google_compute_target_http_proxy.redirect
}

moved {
  from = google_compute_global_forwarding_rule.http
  to   = module.cloud_run.google_compute_global_forwarding_rule.http
}

# Supports users who applied the intermediate Cloud Run module layout before
# the shared certificate was moved back to the root module.
moved {
  from = module.cloud_run.google_compute_managed_ssl_certificate.application
  to   = google_compute_managed_ssl_certificate.application
}
