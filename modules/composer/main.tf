resource "google_composer_environment" "composer_env" {
  name    = var.environment_name
  project = var.project_id
  region  = var.region

  config {
    software_config {
      image_version = var.image_version

      airflow_config_overrides = {
        "core-dags_are_paused_at_creation" = "true"
      }
    }

    node_config {
      network         = var.network_id
      subnetwork      = var.subnet_id
      service_account = var.composer_sa_email
    }
  }
}

# Grant Vertex AI Workbench SA access to write generated Airflow DAGs directly to Composer's DAG bucket
resource "google_storage_bucket_iam_member" "workbench_dag_access" {
  bucket = google_composer_environment.composer_env.storage_config[0].bucket
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${var.workbench_sa_email}"
}
