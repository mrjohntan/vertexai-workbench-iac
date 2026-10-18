# Project Memory: Vertex AI Workbench Testing Environment

## Session Information
- **Branch**: `feat/workbench-testing-env`
- **Target GCP Region**: `asia-southeast1` (Singapore)
- **Primary Goal**: Terraform configuration for private Vertex AI Workbench, Dataproc remote kernel, and Cloud Composer 3 scheduling.

---

## Active Task Roadmap

- [x] 1. Root configuration: Scaffold `versions.tf`, `variables.tf`, and enable project APIs in `main.tf`.
- [x] 2. Networking module: Implement `modules/networking` (VPC, Subnet with Private Google Access, Cloud Router, Cloud NAT, Firewall rules).
- [x] 3. IAM module: Implement `modules/iam` (Service Accounts, least-privilege roles, user impersonation).
- [x] 4. Storage module: Implement `modules/storage` (Test data bucket, Dataproc staging bucket, IAM grants).
- [x] 5. Dataproc module: Implement `modules/dataproc` (Single-node cluster, Component Gateway, Jupyter component).
- [x] 6. Composer module: Implement `modules/composer` (Composer 3 Small environment, DAG bucket permissions).
- [ ] 7. Workbench module: Implement `modules/workbench` (Private `google_workbench_instance`, instance owner, SA attachment).
- [ ] 8. Root orchestration & outputs: Wire modules in `main.tf`, declare outputs in `outputs.tf`, create `terraform.tfvars.example`.
- [ ] 9. Documentation: Create operational runbook in `docs/RUNBOOK.md` and user-facing `README.md`.
- [ ] 10. Closeout verification: Linting, formatting, validation, and review pass.

---

## Current Step
- Ready to start Task 1.
