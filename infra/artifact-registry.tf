resource "google_artifact_registry_repository" "images" {
  location      = var.region
  repository_id = "onepiecetcg"
  description   = "Docker images for One Piece TCG"
  format        = "DOCKER"

  depends_on = [google_project_service.required]
}

resource "terraform_data" "build_api_image" {
  input            = local.image_tag
  triggers_replace = [local.image_tag]

  provisioner "local-exec" {
    working_dir = local.repository_root
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -eu
      docker build -f docker/api.Dockerfile -t "$IMAGE" .
      docker push "$IMAGE"
    EOT
    environment = { IMAGE = local.api_image }
  }

  depends_on = [google_artifact_registry_repository.images]
}

resource "terraform_data" "build_web_image" {
  input            = local.image_tag
  triggers_replace = [local.image_tag]

  provisioner "local-exec" {
    working_dir = local.repository_root
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -eu
      docker build -f docker/web.Dockerfile -t "$IMAGE" .
      docker push "$IMAGE"
    EOT
    environment = { IMAGE = local.web_image }
  }

  depends_on = [google_artifact_registry_repository.images]
}
