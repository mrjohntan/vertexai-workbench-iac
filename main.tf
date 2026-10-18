# Required Google Cloud APIs enablement
locals {
  required_services = [
    "compute.googleapis.com",
    "notebooks.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(locals.required_services)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
