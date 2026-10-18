# Specification: Vertex AI Workbench Testing Environment on GCP with Terraform

## 1. Overview & Objectives

This specification defines a modular Terraform architecture to bootstrap a secure, private-networked testing environment within a target Google Cloud Project in the **`asia-southeast1` (Singapore)** region.

The environment provisions and integrates:
1. **Private VPC Networking & NAT**: Isolated private subnet with Private Google Access, Cloud Router + Cloud NAT for outbound dependency fetching, and restricted firewall rules.
2. **Vertex AI Workbench Instance**: A private `google_workbench_instance` (no external IP) attached to a dedicated service account, accessible via Google Cloud Console Web Proxy, with user impersonation and direct read/write access to a dedicated Cloud Storage data bucket.
3. **Dataproc Single-Node Cluster**: Configured as an internal-only cluster with Component Gateway and Jupyter/Spark components enabled to serve as the remote execution kernel for the Workbench instance.
4. **Cloud Composer 3 Environment**: A lightweight (Small) private Cloud Composer 3 environment accessible by the Workbench instance for notebook workflow and DAG scheduling.
5. **Least-Privilege IAM**: Dedicated service accounts for each component with minimal cross-service bindings and support for user impersonation.

---

## 2. Goals & Non-Goals

### Goals
- Fully automated provisioning using standard Terraform (Google / Google-Beta providers).
- Strict private networking: no public IP addresses assigned to VMs (Workbench, Dataproc, Composer).
- Turnkey integration:
  - Vertex AI Workbench detects and connects to the Dataproc cluster as a remote kernel.
  - Vertex AI Workbench user can schedule notebook executions into the Cloud Composer 3 environment.
  - Workbench service account has granular access to a dedicated Cloud Storage bucket for testing datasets.
  - Specified user can impersonate the Workbench service account.
- Cost-conscious testing footprint (single-node Dataproc, small Composer 3 environment, standard Workbench VM).

### Non-Goals
- Production high-availability (HA multi-node Dataproc, large Composer cluster, multi-region failover).
- Direct internet inbound ingress (all interactive access is handled via GCP Console Proxy / IAP).
- Multi-project / Shared VPC topology (all resources reside inside a single designated testing GCP project).

---

## 3. Architecture & Components

```
                     Google Cloud (Project: var.project_id)
                     Region: asia-southeast1 (Singapore)
 ┌──────────────────────────────────────────────────────────────────────────┐
 │ VPC Network (test-vertex-vpc)                                            │
 │                                                                          │
 │   Private Subnet: 10.10.0.0/24 (Private Google Access Enabled)           │
 │   ┌────────────────────────┐  ┌───────────────────────┐                  │
 │   │ Vertex AI Workbench    │  │ Dataproc Single-Node  │                  │
 │   │ (No Public IP)         │  │ Cluster (Internal IP) │                  │
 │   │ SA: sa-workbench       │  │ SA: sa-dataproc       │                  │
 │   └───────────┬────────────┘  └───────────▲───────────┘                  │
 │               │ Remote Kernel Connection  │                              │
 │               └───────────────────────────┘                              │
 │                                                                          │
 │   ┌───────────────────────────────────────────────────┐                  │
 │   │ Cloud Composer 3 Environment (Small, Private IP)  │                  │
 │   │ SA: sa-composer                                   │                  │
 │   └───────────────────────────▲───────────────────────┘                  │
 │               Deploy DAGs     │                                          │
 │               ────────────────┘                                          │
 └───────────────────────────────┬──────────────────────────────────────────┘
                                 │ Cloud NAT Gateway
                                 ▼
                         Outbound Internet (PyPI, Conda, Apt only)
```

### 3.1 Networking (`modules/networking`)
- **VPC Network**: `google_compute_network` with `auto_create_subnetworks = false`.
- **Subnet**: `google_compute_subnetwork` in `asia-southeast1`:
  - CIDR: `10.10.0.0/24` (configurable via variable).
  - `private_ip_google_access = true`.
- **Cloud Router & NAT**:
  - `google_compute_router` in `asia-southeast1`.
  - `google_compute_router_nat` configured for `LIST_OF_SUBNETWORKS` to allow outbound package downloads (e.g. PyPI, conda, apt) from private instances without external IPs.
- **Firewall Rules**:
  - `allow-internal`: Ingress rule allowing `tcp`, `udp`, and `icmp` across `10.10.0.0/24` for inter-node communication (Spark ports `7077`, `4040-4050`, Jupyter daemon, etc.).
  - `allow-iap-ssh`: Ingress rule allowing TCP port 22 strictly from Google Cloud Identity-Aware Proxy (CIDR `35.235.240.0/20`) for secure break-glass administration.

### 3.2 IAM & Service Accounts (`modules/iam`)
- **Workbench Service Account (`sa-workbench`)**:
  - Attached to the Vertex AI Workbench instance.
  - Roles granted:
    - `roles/notebooks.runner`: Execution permissions for Vertex AI Workbench.
    - `roles/dataproc.editor`: List Dataproc clusters and submit jobs.
    - `roles/composer.user`: Access Composer environment details and trigger workflows.
- **User Impersonation**:
  - A variable `workbench_user_email` (e.g., `user:developer@example.com` or `group:team@example.com`).
  - Roles granted to `workbench_user_email` on the `sa-workbench` resource:
    - `roles/iam.serviceAccountUser`: Allows user to deploy or run compute under this SA identity.
    - `roles/iam.serviceAccountTokenCreator`: Allows explicit impersonation to generate OAuth2 tokens.
- **Dataproc Service Account (`sa-dataproc`)**:
  - Roles granted:
    - `roles/dataproc.worker`: Run cluster components and communicate with the Dataproc control plane.
- **Composer Service Account (`sa-composer`)**:
  - Roles granted:
    - `roles/composer.worker`: Required for Cloud Composer 3 environment workers and scheduler.

### 3.3 Storage (`modules/storage`)
- **Data Storage Bucket**: `google_storage_bucket` in `asia-southeast1` (e.g. `var.project_id-test-data`).
  - Uniform bucket-level access enabled.
  - Versioning enabled (optional, default true).
  - IAM Binding: `roles/storage.objectUser` granted to `sa-workbench` (read, write, delete data objects).
- **Dataproc Staging Bucket**: Dedicated bucket in `asia-southeast1` for Dataproc cluster temporary files and job artifacts, with `roles/storage.objectAdmin` granted to `sa-dataproc`.

### 3.4 Vertex AI Workbench (`modules/workbench`)
- **Resource**: `google_workbench_instance` in `asia-southeast1-a` (or user-specified zone).
- **Compute Specs**: Machine type `e2-standard-4` (configurable), 100 GB balanced boot disk.
- **Network Configuration**:
  - Attached to the private subnet via `gce_setup.network_interfaces`.
  - `gce_setup.disable_public_ip = true`: No public IP assigned.
- **Security & Access**:
  - `gce_setup.service_accounts`: Configured with `sa-workbench.email`.
  - `gce_setup.vm_image`: `project = "cloud-notebooks-managed"`, `family = "workbench-instances"`.
  - `instance_owners = [var.workbench_user_email]`: Allows the user to access the web UI via Google Cloud Console reverse proxy.
  - Network tags: `["vertex-workbench", "private-workload"]`.

### 3.5 Dataproc Cluster (`modules/dataproc`)
- **Resource**: `google_dataproc_cluster` in `asia-southeast1`.
- **Sizing & Single-Node Topology**:
  - `cluster_config.master_config`: 1 master instance (`n2-standard-4` or `e2-standard-4`).
  - `cluster_config.worker_config`: Omitted entirely (Google Cloud API requirement for single-node Dataproc).
  - Software config property in `cluster_config.software_config.override_properties`:
    - `"dataproc:dataproc.allow.zero.workers" = "true"`.
- **Network Configuration**:
  - Attached to the private subnet via `cluster_config.gce_cluster_config.subnetwork`.
  - `cluster_config.gce_cluster_config.internal_ip_only = true`.
  - `cluster_config.gce_cluster_config.service_account = sa-dataproc.email`.
  - Network tags: `["dataproc-node", "private-workload"]`.
- **Component Gateway & Kernels**:
  - `cluster_config.endpoint_config.enable_http_port_access = true`.
  - `cluster_config.software_config.optional_components = ["JUPYTER"]`.

### 3.6 Cloud Composer 3 (`modules/composer`)
- **Resource**: `google_composer_environment` in `asia-southeast1`.
- **Version**: Cloud Composer 3 (`image_version = "composer-3-airflow-2.9.3-build.20"` or compatible Composer 3 release).
- **Node Config**:
  - `service_account = sa-composer.email`.
  - Attached to the private VPC subnet via `network = ...` and `subnetwork = ...`.
- **Cross-Service Wiring for Notebook Scheduling**:
  - The Composer DAGs bucket (`gs://<composer-env-bucket>/dags`) IAM binding:
    - `roles/storage.objectUser` granted to `sa-workbench`.
  - This allows Vertex AI Workbench's "Schedule Notebook" tool to write generated Airflow DAGs directly into the Composer environment.

---

## 4. Module Directory Structure

```
vertexai-workbench/
├── main.tf                    # Root orchestrator: provider config, project API activations, module calls
├── variables.tf               # Global input variables (project_id, region, zone, user_email, etc.)
├── outputs.tf                 # Key outputs (workbench proxy URI, dataproc cluster name, composer web UI, GCS data bucket)
├── terraform.tfvars.example   # Example inputs template
└── modules/
    ├── networking/
    │   ├── main.tf            # VPC, Subnet, Cloud Router, Cloud NAT, Firewall rules
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/
    │   ├── main.tf            # Service accounts, role grants, user impersonation bindings
    │   ├── variables.tf
    │   └── outputs.tf
    ├── storage/
    │   ├── main.tf            # Test data bucket, Dataproc staging bucket
    │   ├── variables.tf
    │   └── outputs.tf
    ├── dataproc/
    │   ├── main.tf            # Single-node Dataproc cluster, Component Gateway
    │   ├── variables.tf
    │   └── outputs.tf
    ├── composer/
    │   ├── main.tf            # Cloud Composer 3 environment, DAG bucket permissions
    │   ├── variables.tf
    │   └── outputs.tf
    └── workbench/
        ├── main.tf            # Vertex AI Workbench instance, private IP, instance owner
        ├── variables.tf
        └── outputs.tf
```

---

## 5. Required GCP APIs
The root module will enable the following APIs via `google_project_service`:
- `compute.googleapis.com` (Compute Engine & VPC networking)
- `notebooks.googleapis.com` (Vertex AI Workbench)
- `dataproc.googleapis.com` (Dataproc)
- `composer.googleapis.com` (Cloud Composer)
- `storage.googleapis.com` (Cloud Storage)
- `iam.googleapis.com` (Identity and Access Management)
- `cloudresourcemanager.googleapis.com` (Resource Manager)

---

## 6. Verification & End-to-End Validation Plan

1. **Syntax & Static Analysis**:
   - `terraform fmt -check`
   - `terraform validate`
2. **Infrastructure Deployment**:
   - `terraform plan -var-file=terraform.tfvars`
   - `terraform apply`
3. **Functional Verification**:
   - **Workbench Access**: Navigate to Google Cloud Console > Vertex AI > Workbench > Click "Open JupyterLab" via Google proxy URI.
   - **User Impersonation & GCS Access**:
     - Inside JupyterLab terminal, verify active credentials: `gcloud auth list` shows the instance running as `sa-workbench`.
     - Test GCS read/write: `gsutil cp test.txt gs://<test-data-bucket>/` and verify write succeeds.
   - **Dataproc Remote Kernel**:
     - Open a new notebook in Workbench. In the kernel selection dropdown, verify the Dataproc PySpark / Spark cluster kernel appears and runs a simple `spark.range(100).count()` test.
   - **Composer Scheduling**:
     - From Workbench JupyterLab menu, select "Schedule notebook run", select the provisioned Cloud Composer environment, and verify the generated DAG appears in the Composer Airflow DAGs list.
