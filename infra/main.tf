locals {
  repository_root = abspath("${path.root}/..")
  image_registry  = "${var.region}-docker.pkg.dev/${var.project_id}/onepiecetcg"
  image_tag       = data.external.git.result.sha
  api_image       = "${local.image_registry}/api:${local.image_tag}"
  web_image       = "${local.image_registry}/web:${local.image_tag}"
  web_origin      = "https://${var.web_domain}"
  api_origin      = "https://${var.api_domain}"
}

data "external" "git" {
  program = [
    "bash",
    "-c",
    <<-EOT
      set -eu
      if [ -n "$(git status --porcelain)" ]; then
        echo "The repository must have no uncommitted changes before deployment." >&2
        exit 1
      fi
      printf '{"sha":"%s"}' "$(git rev-parse --verify HEAD)"
    EOT
  ]
}

resource "google_project_service" "required" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}
