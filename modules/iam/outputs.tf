output "workbench_sa_email" {
  value       = google_service_account.workbench.email
  description = "The email address of the Vertex AI Workbench service account."
}

output "workbench_sa_id" {
  value       = google_service_account.workbench.id
  description = "The fully qualified ID of the Vertex AI Workbench service account."
}

output "dataproc_sa_email" {
  value       = google_service_account.dataproc.email
  description = "The email address of the Dataproc cluster service account."
}

output "composer_sa_email" {
  value       = google_service_account.composer.email
  description = "The email address of the Cloud Composer 3 service account."
}
