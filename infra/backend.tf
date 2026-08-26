terraform {
  backend "gcs" {
    prefix = "onepiecetcg/production"
  }
}
