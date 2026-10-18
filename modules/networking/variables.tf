variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region for the subnetwork, router, and NAT."
  default     = "asia-southeast1"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network."
  default     = "test-vertex-vpc"
}

variable "subnet_cidr" {
  type        = string
  description = "The primary IPv4 CIDR range for the private subnetwork."
  default     = "10.10.0.0/24"
}
