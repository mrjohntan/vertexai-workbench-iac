variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region for the Cloud Composer 3 environment."
  default     = "asia-southeast1"
}

variable "network_id" {
  type        = string
  description = "The VPC network ID."
}

variable "subnet_id" {
  type        = string
  description = "The subnetwork ID."
}

variable "composer_sa_email" {
  type        = string
  description = "The service account email for Cloud Composer 3 workers."
}

variable "workbench_sa_email" {
  type        = string
  description = "The service account email of the Workbench instance to grant DAG write access."
}

variable "environment_name" {
  type        = string
  description = "The name of the Cloud Composer 3 environment."
  default     = "test-composer-env"
}

variable "image_version" {
  type        = string
  description = "The Cloud Composer 3 image version."
  default     = "composer-3-airflow-3.3.1"
}
