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
  description = "The machine type for the single-node Dataproc master instance."
  default     = "n2-standard-4"
}
