variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region for the Dataproc cluster."
  default     = "asia-southeast1"
}

variable "subnet_id" {
  type        = string
  description = "The subnetwork ID/self_link where the cluster nodes reside."
}

variable "dataproc_sa_email" {
  type        = string
  description = "The service account email attached to the Dataproc cluster."
}

variable "staging_bucket_name" {
  type        = string
  description = "The GCS bucket name for Dataproc staging."
}

variable "temp_bucket_name" {
  type        = string
  description = "The GCS bucket name for Dataproc temp files."
}

variable "master_machine_type" {
  type        = string
  description = "The Compute Engine machine type for the Dataproc master node."
  default     = "n2-standard-4"
}

variable "cluster_name" {
  type        = string
  description = "The name of the Dataproc cluster."
  default     = "test-dataproc-kernel"
}

variable "idle_stop_ttl" {
  type        = string
  description = "The duration to keep the Dataproc cluster running while idle before automatically stopping it (must end with 's', e.g. '1800s' for 30 minutes). Valid range: [600s, 1209600s]."
  default     = "1800s"
}
