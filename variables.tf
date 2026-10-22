variable "project_id" {
  type        = string
  description = "The target Google Cloud Project ID where resources will be provisioned."
}

variable "region" {
  type        = string
  description = "The primary Google Cloud region for regional resources."
  default     = "asia-southeast1"
}

variable "zone" {
  type        = string
  description = "The Google Cloud zone for zonal resources like Vertex AI Workbench."
  default     = "asia-southeast1-a"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network to create."
  default     = "test-vertex-vpc"
}

variable "subnet_cidr" {
  type        = string
  description = "The CIDR range for the private testing subnetwork."
  default     = "10.10.0.0/24"
}

variable "workbench_user_email" {
  type        = string
  description = "The email of the user or group who will own the Workbench instance and impersonate the service account (e.g. user:user@example.com)."
}

variable "workbench_machine_type" {
  type        = string
  description = "The machine type for the Vertex AI Workbench instance."
  default     = "e2-standard-4"
}

variable "dataproc_master_machine_type" {
  type        = string
  description = "The machine type for the Dataproc master instance."
  default     = "e2-standard-2"
}

variable "dataproc_worker_machine_type" {
  type        = string
  description = "The machine type for the Dataproc worker instances."
  default     = "e2-standard-2"
}

variable "dataproc_worker_num_instances" {
  type        = number
  description = "The number of worker instances in the Dataproc cluster."
  default     = 2
}

variable "dataproc_idle_stop_ttl" {
  type        = string
  description = "The duration of inactivity before the Dataproc cluster automatically stops (must end with 's', e.g. '1800s' for 30 minutes). Valid range: [600s, 1209600s]."
  default     = "1800s"
}

variable "workbench_idle_timeout_seconds" {
  type        = number
  description = "Idle timeout in seconds before the Vertex AI Workbench instance automatically shuts down (default 1800 = 30 minutes)."
  default     = 1800
}

variable "enable_composer" {
  type        = bool
  description = "Whether to provision the Cloud Composer 3 environment. Set to false to defer deployment."
  default     = false
}

variable "dataproc_image_version" {
  type        = string
  description = "The Dataproc image version supporting Spark 3 (default: 2.3-debian12, the latest Dataproc image line with Spark 3.5.x)."
  default     = "2.3-debian12"
}

