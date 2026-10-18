resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. Dedicated Cloud Storage Bucket for Testing Datasets
resource "google_storage_bucket" "data_bucket" {
  name                        = "${var.project_id}-test-data-${random_id.bucket_suffix.hex}"
  project                     = var.project_id
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Grant Vertex AI Workbench SA access to read/write/delete data objects
resource "google_storage_bucket_iam_member" "workbench_data_access" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${var.workbench_sa_email}"
}

# 2. Dedicated Cloud Storage Bucket for Dataproc Staging
resource "google_storage_bucket" "dataproc_staging" {
  name                        = "${var.project_id}-dataproc-staging-${random_id.bucket_suffix.hex}"
  project                     = var.project_id
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Grant Dataproc SA admin permissions on its staging bucket
resource "google_storage_bucket_iam_member" "dataproc_staging_access" {
  bucket = google_storage_bucket.dataproc_staging.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.dataproc_sa_email}"
}
