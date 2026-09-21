resource "google_compute_global_address" "application" {
  name = "onepiecetcg-ip"
}

resource "google_compute_region_network_endpoint_group" "web" {
  name                  = "onepiecetcg-web-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.web.name
  }
}

resource "google_compute_region_network_endpoint_group" "api" {
  name                  = "onepiecetcg-api-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.api.name
  }
}

resource "google_compute_backend_service" "web" {
  name                  = "onepiecetcg-web-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.web.id
  }
}

resource "google_compute_backend_service" "api" {
  name                  = "onepiecetcg-api-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.api.id
  }
}

resource "google_compute_url_map" "https" {
  name            = "onepiecetcg-https-map"
  default_service = google_compute_backend_service.web.id

  host_rule {
    hosts        = [var.web_domain]
    path_matcher = "web"
  }
  host_rule {
    hosts        = [var.api_domain]
    path_matcher = "api"
  }
  path_matcher {
    name            = "web"
    default_service = google_compute_backend_service.web.id
  }
  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.api.id
  }
}

resource "google_compute_target_https_proxy" "application" {
  name             = "onepiecetcg-https-proxy"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [var.ssl_certificate_id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "onepiecetcg-https-forwarding-rule"
  target                = google_compute_target_https_proxy.application.id
  port_range            = "443"
  ip_address            = google_compute_global_address.application.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_url_map" "http_redirect" {
  name = "onepiecetcg-http-redirect"
  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "onepiecetcg-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "onepiecetcg-http-forwarding-rule"
  target                = google_compute_target_http_proxy.redirect.id
  port_range            = "80"
  ip_address            = google_compute_global_address.application.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
