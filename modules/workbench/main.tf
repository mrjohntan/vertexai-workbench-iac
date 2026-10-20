locals {
  # google_workbench_instance expects plain user email in instance_owners
  owner_email = replace(var.workbench_user_email, "/^(user|group|serviceAccount):/", "")
}

resource "google_workbench_instance" "instance" {
  name            = var.instance_name
  project         = var.project_id
  location        = var.zone
  instance_owners = [local.owner_email]

  gce_setup {
    machine_type      = var.machine_type
    disable_public_ip = true

    network_interfaces {
      network  = var.network_id
      subnet   = var.subnet_id
      nic_type = "GVNIC"
    }

    service_accounts {
      email = var.workbench_sa_email
    }

    vm_image {
      project = "cloud-notebooks-managed"
      family  = "workbench-instances"
    }

    boot_disk {
      disk_size_gb = var.boot_disk_size_gb
      disk_type    = "PD_BALANCED"
    }

    metadata = {
      idle-timeout-seconds    = tostring(var.idle_timeout_seconds)
      enable-guest-attributes = "TRUE"
    }

    tags = ["vertex-workbench", "private-workload"]
  }

  labels = {
    environment = "testing"
    managed_by  = "terraform"
  }
}
