# Vertex AI Workbench Testing Environment on Google Cloud

Automated Terraform codebase to bootstrap a secure, private-networked data science testing environment in **`asia-southeast1` (Singapore)**.

## Architecture Highlights

- **Private Networking**: Custom VPC (`10.10.0.0/24`) with Private Google Access.
- **Outbound NAT**: Cloud Router + Cloud NAT automatically enables private instances (Workbench VM, Dataproc nodes) to download libraries from PyPI, Conda, and Debian APT without public IPs.
- **Vertex AI Workbench**: A private `google_workbench_instance` (strictly no external IP, `disable_public_ip = true`), with outbound package egress via Cloud NAT, accessible via Google Cloud Console Web Proxy, attached to a dedicated least-privilege service account (`sa-workbench`).
- **Apache Spark Kernels**: Workbench metadata enables the Managed Service for Apache Spark JupyterLab kernels (`disable-mixer = "false"`) and pre-binds to the provisioned Dataproc cluster.
- **User Impersonation & Cloud Storage Access**: Configured with IAM impersonation (`roles/iam.serviceAccountUser` & `roles/iam.serviceAccountTokenCreator`) for the assigned user, granting write/read access to a dedicated test data bucket.
- **Dataproc Remote Kernel (Spark 3 Support)**: Single-node Dataproc cluster running the latest Dataproc 2.3 image (`2.3-debian12`, supporting Apache Spark 3.5.x) in the private subnet with Component Gateway and Jupyter/Spark components enabled to serve as the remote kernel for Workbench notebooks.
- **Cloud Composer 3 Scheduling**: A lightweight (Small) Cloud Composer 3 environment with cross-service IAM permissions allowing Workbench users to publish and schedule notebook DAGs directly into Apache Airflow.

---

## Directory Structure

```
├── main.tf                    # Root orchestrator: API activations & child module calls
├── variables.tf               # Root input variables
├── outputs.tf                 # Key outputs (proxy URL, Airflow URL, cluster names, buckets)
├── versions.tf                # Provider versions (google & google-beta >= 5.0.0, < 7.0.0)
├── terraform.tfvars.example   # Example input configuration
├── modules/
│   ├── networking/            # VPC, private subnet, Cloud Router, Cloud NAT, firewall rules
│   ├── iam/                   # Service accounts, role grants, user impersonation bindings
│   ├── storage/               # Test data bucket, Dataproc staging & temp buckets
│   ├── dataproc/              # Single-node Dataproc cluster with Component Gateway
│   ├── composer/              # Cloud Composer 3 environment & DAG bucket permissions
│   └── workbench/             # Private Vertex AI Workbench instance & instance owner
└── docs/
    ├── SPEC.md                # Architectural design and technical specification
    └── RUNBOOK.md             # Operational procedures, testing steps, and troubleshooting
```

---

## Quickstart

### 1. Prerequisites
- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) authenticated with permissions on the target GCP project:
  ```bash
  gcloud auth application-default login
  gcloud config set project <YOUR_PROJECT_ID>
  ```
- [Terraform CLI](https://developer.hashicorp.com/terraform/install) (>= 1.5.0).

### 2. Configure Variables
Copy `terraform.tfvars.example` to `terraform.tfvars` and customize your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_id           = "your-gcp-project-id"
region               = "asia-southeast1"
zone                 = "asia-southeast1-a"
workbench_user_email = "user:developer@example.com"

# Optional settings
workbench_idle_timeout_seconds = 1800   # 30-min idle shutdown (default: 1800)
dataproc_idle_stop_ttl         = "1800s" # 30-min Dataproc scheduled stop (default: "1800s")
enable_composer                = false  # Set to true when you want Cloud Composer 3
```

### 3. Deploy
```bash
# Initialize providers and modules
terraform init

# Review execution plan
terraform plan

# Provision resources
terraform apply
```

### 4. Teardown
To destroy all provisioned testing resources and avoid recurring charges:
```bash
terraform destroy
```

For comprehensive step-by-step validation procedures, refer to the [Operational Runbook](file:///Users/johntan/Projects/vertexai-workbench/docs/RUNBOOK.md).
