output "workbench_instance_name" {
  value       = module.workbench.instance_name
  description = "The name of the Vertex AI Workbench instance."
}

output "workbench_proxy_uri" {
  value       = module.workbench.proxy_uri
  description = "The secure Google Cloud proxy URI to access JupyterLab on the private Workbench instance."
}

output "workbench_sa_email" {
  value       = module.iam.workbench_sa_email
  description = "The email address of the service account attached to the Workbench instance."
}

output "dataproc_cluster_name" {
  value       = module.dataproc.cluster_name
  description = "The name of the single-node Dataproc cluster."
}

output "composer_env_name" {
  value       = try(module.composer[0].composer_env_name, null)
  description = "The name of the Cloud Composer 3 environment (null if enable_composer is false)."
}

output "composer_airflow_uri" {
  value       = try(module.composer[0].airflow_uri, null)
  description = "The Web UI URI for Cloud Composer Apache Airflow (null if enable_composer is false)."
}

output "composer_dag_bucket" {
  value       = try(module.composer[0].gcs_bucket_name, null)
  description = "The Cloud Storage bucket automatically created by Cloud Composer for DAGs and plugins (null if enable_composer is false)."
}

output "composer_dags_path" {
  value       = try(module.composer[0].dags_gcs_prefix, null)
  description = "The full Cloud Storage path (gs://<bucket>/dags) where Airflow DAG files should be uploaded (null if enable_composer is false)."
}

output "data_bucket_name" {
  value       = module.storage.data_bucket_name
  description = "The dedicated Cloud Storage bucket name for test datasets."
}

output "data_bucket_url" {
  value       = module.storage.data_bucket_url
  description = "The gs:// URL of the dedicated test data bucket."
}

output "vpc_network_name" {
  value       = module.networking.network_name
  description = "The name of the VPC network."
}

output "subnet_name" {
  value       = module.networking.subnet_name
  description = "The name of the private subnetwork."
}
