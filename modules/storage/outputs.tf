output "data_bucket_name" {
  value       = google_storage_bucket.data_bucket.name
  description = "The name of the dedicated test data GCS bucket."
}

output "data_bucket_url" {
  value       = google_storage_bucket.data_bucket.url
  description = "The gs:// URL of the dedicated test data GCS bucket."
}

output "dataproc_staging_bucket_name" {
  value       = google_storage_bucket.dataproc_staging.name
  description = "The name of the Dataproc staging GCS bucket."
}

output "dataproc_temp_bucket_name" {
  value       = google_storage_bucket.dataproc_temp.name
  description = "The name of the Dataproc temp GCS bucket."
}
