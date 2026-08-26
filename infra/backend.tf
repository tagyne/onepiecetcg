terraform {
  backend "gcs" {
    bucket = "onepiecetcg-terraform-state-bucket"
    prefix = "onepiecetcg/production"
  }
}
