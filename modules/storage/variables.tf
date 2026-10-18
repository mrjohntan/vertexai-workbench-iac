variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region for the storage buckets."
  default     = "asia-southeast1"
}

variable "workbench_sa_email" {
  type        = string
  description = "The email of the Vertex AI Workbench service account."
}

variable "dataproc_sa_email" {
  type        = string
  description = "The email of the Dataproc cluster service account."
}
