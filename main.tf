# Required Google Cloud APIs enablement
locals {
  required_services = [
    "compute.googleapis.com",
    "notebooks.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_services)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# 1. Networking Module (VPC, Subnet, Cloud Router, Cloud NAT, Firewalls)
module "networking" {
  source = "./modules/networking"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  subnet_cidr  = var.subnet_cidr

  depends_on = [google_project_service.required_apis]
}

# 2. IAM Module (Service Accounts, Least-Privilege Roles, Impersonation)
module "iam" {
  source = "./modules/iam"

  project_id           = var.project_id
  workbench_user_email = var.workbench_user_email

  depends_on = [google_project_service.required_apis]
}

# 3. Storage Module (Data Bucket, Dataproc Staging Bucket, Bucket IAM)
module "storage" {
  source = "./modules/storage"

  project_id         = var.project_id
  region             = var.region
  workbench_sa_email = module.iam.workbench_sa_email
  dataproc_sa_email  = module.iam.dataproc_sa_email

  depends_on = [google_project_service.required_apis]
}

# 4. Dataproc Module (Single-Node Cluster, Component Gateway, Jupyter)
module "dataproc" {
  source = "./modules/dataproc"

  project_id          = var.project_id
  region              = var.region
  subnet_id           = module.networking.subnet_id
  dataproc_sa_email   = module.iam.dataproc_sa_email
  staging_bucket_name = module.storage.dataproc_staging_bucket_name
  temp_bucket_name    = module.storage.dataproc_temp_bucket_name
  master_machine_type = var.dataproc_master_machine_type
  idle_stop_ttl       = var.dataproc_idle_stop_ttl

  depends_on = [google_project_service.required_apis]
}

# 5. Cloud Composer 3 Module (Composer 3 Small, Private Subnet, DAG Access)
module "composer" {
  count  = var.enable_composer ? 1 : 0
  source = "./modules/composer"

  project_id         = var.project_id
  region             = var.region
  network_id         = module.networking.network_id
  subnet_id          = module.networking.subnet_id
  composer_sa_email  = module.iam.composer_sa_email
  workbench_sa_email = module.iam.workbench_sa_email

  depends_on = [google_project_service.required_apis]
}

# 6. Vertex AI Workbench Module (Private Instance, Owner, Attached SA)
module "workbench" {
  source = "./modules/workbench"

  project_id           = var.project_id
  zone                 = var.zone
  network_id           = module.networking.network_id
  subnet_id            = module.networking.subnet_id
  workbench_sa_email   = module.iam.workbench_sa_email
  workbench_user_email = var.workbench_user_email
  machine_type         = var.workbench_machine_type
  idle_timeout_seconds = var.workbench_idle_timeout_seconds

  depends_on = [google_project_service.required_apis]
}
