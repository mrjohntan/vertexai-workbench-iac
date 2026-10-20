locals {
  user_member = (
    startswith(var.workbench_user_email, "user:") ||
    startswith(var.workbench_user_email, "group:") ||
    startswith(var.workbench_user_email, "serviceAccount:")
  ) ? var.workbench_user_email : "user:${var.workbench_user_email}"

  workbench_roles = [
    "roles/notebooks.runner",
    "roles/dataproc.editor",
    "roles/composer.user"
  ]
}

# 1. Vertex AI Workbench Service Account
resource "google_service_account" "workbench" {
  account_id   = "sa-workbench"
  display_name = "Vertex AI Workbench Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "workbench_roles" {
  for_each = toset(local.workbench_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workbench.email}"
}

# User Impersonation: Allow user to act as and create tokens for Workbench SA
resource "google_service_account_iam_member" "user_impersonate_user" {
  service_account_id = google_service_account.workbench.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.user_member
}

resource "google_service_account_iam_member" "user_impersonate_token" {
  service_account_id = google_service_account.workbench.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.user_member
}

# 2. Dataproc Cluster Service Account
resource "google_service_account" "dataproc" {
  account_id   = "sa-dataproc"
  display_name = "Dataproc Cluster Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.dataproc.email}"
}

# 3. Cloud Composer 3 Service Account
resource "google_service_account" "composer" {
  account_id   = "sa-composer"
  display_name = "Cloud Composer 3 Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "composer_worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer.email}"
}
