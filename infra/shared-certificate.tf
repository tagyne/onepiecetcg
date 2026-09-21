resource "google_compute_managed_ssl_certificate" "application" {
  name = "onepiecetcg-certificate"

  managed {
    domains = [var.web_domain, var.api_domain]
  }
}
