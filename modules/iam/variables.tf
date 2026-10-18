variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "workbench_user_email" {
  type        = string
  description = "The email identity of the user/group allowed to impersonate the Workbench SA (e.g., user:alice@example.com)."
}
