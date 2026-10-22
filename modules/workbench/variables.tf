variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "zone" {
  type        = string
  description = "The GCP zone for the Vertex AI Workbench instance."
  default     = "asia-southeast1-a"
}

variable "network_id" {
  type        = string
  description = "The VPC network ID."
}

variable "subnet_id" {
  type        = string
  description = "The subnetwork ID."
}

variable "workbench_sa_email" {
  type        = string
  description = "The service account email attached to the Workbench instance."
}

variable "workbench_user_email" {
  type        = string
  description = "The user email who owns and accesses the instance (e.g. user:alice@example.com or alice@example.com)."
}

variable "instance_name" {
  type        = string
  description = "The name of the Vertex AI Workbench instance."
  default     = "test-workbench-instance"
}

variable "machine_type" {
  type        = string
  description = "The Compute Engine machine type."
  default     = "e2-standard-4"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Boot disk size in GB."
  default     = 150
}

variable "idle_timeout_seconds" {
  type        = number
  description = "Idle timeout in seconds before the workbench instance automatically shuts down (default 1800 = 30 minutes)."
  default     = 1800
}

variable "disable_public_ip" {
  type        = bool
  description = "Whether to disable public IP allocation on the workbench instance (default: true for private egress via Cloud NAT)."
  default     = true
}

variable "dataproc_cluster_name" {
  type        = string
  description = "The target Dataproc cluster name to bind for Apache Spark Jupyter kernels."
  default     = ""
}

variable "dataproc_region" {
  type        = string
  description = "The region of the target Dataproc cluster."
  default     = ""
}

