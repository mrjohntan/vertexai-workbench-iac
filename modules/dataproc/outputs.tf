output "cluster_name" {
  value       = google_dataproc_cluster.cluster.name
  description = "The name of the Dataproc cluster."
}

output "cluster_id" {
  value       = google_dataproc_cluster.cluster.id
  description = "The ID of the Dataproc cluster."
}
