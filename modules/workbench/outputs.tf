output "instance_id" {
  value       = google_workbench_instance.instance.id
  description = "The ID of the Vertex AI Workbench instance."
}

output "instance_name" {
  value       = google_workbench_instance.instance.name
  description = "The name of the Vertex AI Workbench instance."
}

output "proxy_uri" {
  value       = google_workbench_instance.instance.proxy_uri
  description = "The HTTPS proxy URI to connect to JupyterLab on the Workbench instance without a public IP."
}
