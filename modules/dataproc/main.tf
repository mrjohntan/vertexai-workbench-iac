resource "google_dataproc_cluster" "cluster" {
  name    = var.cluster_name
  project = var.project_id
  region  = var.region

  cluster_config {
    staging_bucket = var.staging_bucket_name
    temp_bucket    = var.temp_bucket_name

    lifecycle_config {
      idle_stop_ttl = var.idle_stop_ttl
    }

    master_config {
      num_instances = 1
      machine_type  = var.master_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 50
      }
    }

    worker_config {
      num_instances = var.worker_num_instances
      machine_type  = var.worker_machine_type
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 50
      }
    }

    software_config {
      image_version       = var.image_version
      optional_components = ["JUPYTER"]
    }

    gce_cluster_config {
      subnetwork       = var.subnet_id
      internal_ip_only = true
      service_account  = var.dataproc_sa_email
      tags             = ["dataproc-node", "private-workload"]
    }

    endpoint_config {
      enable_http_port_access = true
    }
  }
}
