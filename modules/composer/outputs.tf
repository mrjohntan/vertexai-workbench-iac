output "composer_env_name" {
  value       = google_composer_environment.composer_env.name
  description = "The name of the Cloud Composer environment."
}

output "airflow_uri" {
  value       = google_composer_environment.composer_env.config[0].airflow_uri
  description = "The URI of the Apache Airflow web interface."
}

output "gcs_bucket_name" {
  value       = google_composer_environment.composer_env.storage_config[0].bucket
  description = "The Cloud Storage bucket name associated with the Cloud Composer environment."
}
