# Implementation Plan: Vertex AI Workbench Testing Environment

This plan derives directly from [docs/SPEC.md](file:///Users/johntan/Projects/vertexai-workbench/docs/SPEC.md) and outlines the sequential, micro-task roadmap for provisioning the infrastructure with Terraform.

---

## Proposed Changes

### Micro-Task 1: Project Scaffolding & Root Provider Configuration
- **Files to create**:
  - `versions.tf`: Declare minimum Terraform version (`>= 1.5.0`), required provider `hashicorp/google` (`>= 5.0.0`) and `hashicorp/google-beta` (`>= 5.0.0`).
  - `variables.tf`: Declare root input variables (`project_id`, `region`, `zone`, `network_name`, `subnet_cidr`, `workbench_user_email`, `workbench_machine_type`, `dataproc_master_machine_type`).
  - `main.tf` (Initial): Declare GCP project service enablement (`compute.googleapis.com`, `notebooks.googleapis.com`, `dataproc.googleapis.com`, `composer.googleapis.com`, `storage.googleapis.com`, `iam.googleapis.com`).
- **Verification**: `terraform init -backend=false` and `terraform validate`.

---

### Micro-Task 2: Networking Module (`modules/networking`)
- **Files to create**:
  - `modules/networking/variables.tf`: `project_id`, `region`, `network_name`, `subnet_cidr`.
  - `modules/networking/main.tf`:
    - `google_compute_network`: Custom VPC (`auto_create_subnetworks = false`).
    - `google_compute_subnetwork`: Private subnet in `asia-southeast1` with `private_ip_google_access = true`.
    - `google_compute_router` & `google_compute_router_nat`: Cloud Router + NAT for private outbound downloads.
    - `google_compute_firewall`: Internal communication rule (`10.10.0.0/24`) and IAP SSH rule (`35.235.240.0/20`).
  - `modules/networking/outputs.tf`: Export `network_id`, `network_name`, `subnet_id`, `subnet_name`.
- **Verification**: Syntactic and schema verification via `terraform validate`.

---

### Micro-Task 3: IAM & Service Accounts Module (`modules/iam`)
- **Files to create**:
  - `modules/iam/variables.tf`: `project_id`, `workbench_user_email`.
  - `modules/iam/main.tf`:
    - `google_service_account.workbench`: `sa-workbench`.
    - `google_service_account.dataproc`: `sa-dataproc`.
    - `google_service_account.composer`: `sa-composer`.
    - IAM role bindings for `sa-workbench` (`roles/notebooks.runner`, `roles/dataproc.editor`, `roles/composer.user`).
    - IAM role bindings for `sa-dataproc` (`roles/dataproc.worker`).
    - IAM role bindings for `sa-composer` (`roles/composer.worker`).
    - Service Account Impersonation bindings on `sa-workbench`: Grant `roles/iam.serviceAccountUser` and `roles/iam.serviceAccountTokenCreator` to `var.workbench_user_email`.
  - `modules/iam/outputs.tf`: Export `workbench_sa_email`, `workbench_sa_id`, `dataproc_sa_email`, `composer_sa_email`.
- **Verification**: Schema validation via `terraform validate`.

---

### Micro-Task 4: Storage Module (`modules/storage`)
- **Files to create**:
  - `modules/storage/variables.tf`: `project_id`, `region`, `workbench_sa_email`, `dataproc_sa_email`.
  - `modules/storage/main.tf`:
    - `google_storage_bucket.data`: Test data bucket in `asia-southeast1` with uniform bucket-level access.
    - `google_storage_bucket.dataproc_staging`: Dataproc staging bucket in `asia-southeast1`.
    - `google_storage_bucket_iam_member.workbench_data_access`: Grant `roles/storage.objectUser` on the data bucket to `var.workbench_sa_email`.
    - `google_storage_bucket_iam_member.dataproc_staging_access`: Grant `roles/storage.objectAdmin` on staging bucket to `var.dataproc_sa_email`.
  - `modules/storage/outputs.tf`: Export `data_bucket_name`, `data_bucket_url`, `dataproc_staging_bucket_name`.
- **Verification**: Schema validation via `terraform validate`.

---

### Micro-Task 5: Dataproc Module (`modules/dataproc`)
- **Files to create**:
  - `modules/dataproc/variables.tf`: `project_id`, `region`, `subnet_name`, `dataproc_sa_email`, `staging_bucket_name`, `master_machine_type`.
  - `modules/dataproc/main.tf`:
    - `google_dataproc_cluster`: Single-node cluster (`num_instances = 1` master, `0` workers) in `asia-southeast1`.
    - Internal IP only (`internal_ip_only = true`), subnet reference.
    - Component Gateway enabled (`enable_http_port_access = true`).
    - Optional component `["JUPYTER"]`.
    - Cluster property `dataproc:dataproc.allow.zero.workers = "true"`.
    - Attached service account: `var.dataproc_sa_email`.
  - `modules/dataproc/outputs.tf`: Export `cluster_name`, `cluster_id`, `master_instance_name`.
- **Verification**: Schema validation via `terraform validate`.

---

### Micro-Task 6: Cloud Composer 3 Module (`modules/composer`)
- **Files to create**:
  - `modules/composer/variables.tf`: `project_id`, `region`, `subnet_id`, `composer_sa_email`, `workbench_sa_email`.
  - `modules/composer/main.tf`:
    - `google_composer_environment`: Composer 3 (`image_version = "composer-3-airflow-2.*"`), `ENVIRONMENT_SIZE_SMALL` in `asia-southeast1`.
    - Node config with `var.composer_sa_email` and private subnet attachment.
    - `google_storage_bucket_iam_member.workbench_composer_dags`: Grant `roles/storage.objectUser` on Composer's GCS DAGs bucket to `var.workbench_sa_email`.
  - `modules/composer/outputs.tf`: Export `composer_env_name`, `airflow_uri`, `gcs_bucket_name`.
- **Verification**: Schema validation via `terraform validate`.

---

### Micro-Task 7: Vertex AI Workbench Module (`modules/workbench`)
- **Files to create**:
  - `modules/workbench/variables.tf`: `project_id`, `zone`, `subnet_id`, `workbench_sa_email`, `workbench_user_email`, `machine_type`.
  - `modules/workbench/main.tf`:
    - `google_workbench_instance`: Instance in `asia-southeast1-a` (or user zone).
    - `disable_public_ip = true`, private subnet attachment.
    - `gce_setup.service_accounts`: Configured with `var.workbench_sa_email`.
    - `instance_owners = [var.workbench_user_email]`.
    - Network tags `["vertex-workbench", "private-workload"]`.
  - `modules/workbench/outputs.tf`: Export `instance_id`, `instance_name`, `proxy_uri`.
- **Verification**: Schema validation via `terraform validate`.

---

### Micro-Task 8: Root Module Orchestration, Outputs & Documentation
- **Files to update / create**:
  - `main.tf`: Instantiate modules (`networking`, `iam`, `storage`, `dataproc`, `composer`, `workbench`) with dependency chains (`depends_on` on project service enablement).
  - `outputs.tf`: Surface `workbench_proxy_uri`, `dataproc_cluster_name`, `composer_airflow_uri`, `data_bucket_url`, `workbench_sa_email`.
  - `terraform.tfvars.example`: Example input file with instructions.
  - `docs/RUNBOOK.md`: Operational test guide (deployment steps, verifying Workbench web UI, running PySpark test on Dataproc remote kernel, scheduling test DAG to Composer, and teardown).
- **Verification**: Full `terraform validate` and `terraform fmt -check`.

---

## Sequential Implementation Checklist

- [ ] 1. Scaffold root provider (`versions.tf`), root input variables (`variables.tf`), and API services in `main.tf`.
- [ ] 2. Implement `modules/networking` (VPC, Subnet, Router, NAT, Firewall).
- [ ] 3. Implement `modules/iam` (Service Accounts, least-privilege bindings, user impersonation).
- [ ] 4. Implement `modules/storage` (Data bucket, Dataproc staging bucket, IAM grants).
- [ ] 5. Implement `modules/dataproc` (Single-node cluster, Component Gateway, Jupyter component).
- [ ] 6. Implement `modules/composer` (Composer 3 Small environment, DAG bucket permissions).
- [ ] 7. Implement `modules/workbench` (Private `google_workbench_instance`, instance owner, SA attachment).
- [ ] 8. Wire root module (`main.tf`, `outputs.tf`, `terraform.tfvars.example`).
- [ ] 9. Create operational guide `docs/RUNBOOK.md`.
- [ ] 10. Perform end-to-end linting, formatting, and validation (`terraform fmt`, `terraform validate`).
