# Implementation Plan: Dataproc Spark 3 & Vertex AI Workbench Private Egress / Spark Kernels

## 1. Summary of Changes
1. **Dataproc Spark 3 Support**:
   - Update `modules/dataproc/main.tf` to use image version `2.3-debian12` (or configurable variable), which is the latest Dataproc image series supporting Apache Spark 3 (Spark 3.5.x).
   - Add `image_version` variable in `modules/dataproc/variables.tf` (default `"2.3-debian12"`).
   - Expose `dataproc_image_version` in root `variables.tf` and wire it into root `main.tf`.
2. **Vertex AI Workbench No External IP & NAT Egress**:
   - Verify and guarantee `gce_setup.disable_public_ip = true` in `modules/workbench/main.tf`. Add variable `disable_public_ip` (default `true`) in `modules/workbench/variables.tf`.
   - Ensure the subnet has Cloud NAT enabled (already present via `google_compute_router_nat.nat` in `modules/networking/main.tf` with `source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"`).
3. **Apache Spark Kernels Enablement on Vertex AI Workbench**:
   - In `modules/workbench/main.tf`, add to `gce_setup.metadata`:
     - `"disable-mixer" = "false"`: Enables Managed Service for Apache Spark (Dataproc) JupyterLab extension and remote Spark kernels.
     - `"dataproc-cluster-name" = var.dataproc_cluster_name`: Links JupyterLab directly to the provisioned Dataproc cluster.
     - `"dataproc-region" = var.dataproc_region`: Sets the region for interactive session management.
   - Add `dataproc_cluster_name` and `dataproc_region` input variables in `modules/workbench/variables.tf`.
   - Wire `cluster_name = module.dataproc.cluster_name` and `dataproc_region = var.region` from root `main.tf` into `module.workbench`.
   - In `modules/iam/main.tf`, ensure `sa-workbench` is granted `roles/iam.serviceAccountUser` on `google_service_account.dataproc` to permit interactive Spark job execution under Dataproc's identity.
4. **Automated Unit Testing & Verification**:
   - Update `tests/test_dataproc_module.py` to assert Spark 3 support via image version `2.3-debian12` and variable definition.
   - Update `tests/test_workbench_module.py` to assert `disable_public_ip = true`, `disable-mixer = "false"`, and Dataproc cluster metadata keys.
   - Update `tests/test_root_orchestration.py` to assert wiring between Dataproc and Workbench modules.
   - Run `python3 -m unittest discover tests` and `terraform validate`.

---

## 2. Sequential Micro-Task Checklist

### Phase 3 Execution Steps (Upon Approval)
- [ ] **Task 1: Dataproc Module Spark 3 Configuration**
  - File: `modules/dataproc/variables.tf` -> Add `image_version` variable defaulting to `"2.3-debian12"`.
  - File: `modules/dataproc/main.tf` -> Update `software_config.image_version = var.image_version`.
  - Verification: `python3 -m unittest tests/test_dataproc_module.py`

- [ ] **Task 2: Vertex AI Workbench Private IP & Spark Kernels Configuration**
  - File: `modules/workbench/variables.tf` -> Add `disable_public_ip` (default `true`), `dataproc_cluster_name` (optional/default `null` or `""`), `dataproc_region` (optional/default `null` or `""`).
  - File: `modules/workbench/main.tf` -> Set `disable_public_ip = var.disable_public_ip`, and in `metadata` add `disable-mixer = "false"`, conditionally add `dataproc-cluster-name` and `dataproc-region`.
  - Verification: `python3 -m unittest tests/test_workbench_module.py`

- [ ] **Task 3: IAM Cross-Service Permissions for Dataproc Kernels**
  - File: `modules/iam/main.tf` -> Add `google_service_account_iam_member.workbench_actas_dataproc` granting `roles/iam.serviceAccountUser` on `google_service_account.dataproc` to `serviceAccount:${google_service_account.workbench.email}`.
  - Verification: `python3 -m unittest tests/test_iam_module.py`

- [ ] **Task 4: Root Module Wiring & Variable Pass-through**
  - File: `variables.tf` -> Add `dataproc_image_version` variable defaulting to `"2.3-debian12"`.
  - File: `main.tf` -> Pass `image_version = var.dataproc_image_version` to `module.dataproc`, and pass `dataproc_cluster_name = module.dataproc.cluster_name` and `dataproc_region = var.region` to `module.workbench`.
  - File: `terraform.tfvars.example` -> Document `dataproc_image_version`.
  - Verification: `terraform validate` and `python3 -m unittest discover tests`

- [ ] **Task 5: Update Test Suites**
  - File: `tests/test_dataproc_module.py` -> Add assertions for `image_version` default `"2.3-debian12"`.
  - File: `tests/test_workbench_module.py` -> Add assertions for `disable-mixer`, `disable_public_ip`, and `dataproc-cluster-name`.
  - File: `tests/test_root_orchestration.py` -> Add assertions for root pass-through to workbench and dataproc.
  - Verification: `python3 -m unittest discover tests`

- [ ] **Task 6: Closeout & Documentation Sync**
  - File: `docs/RUNBOOK.md` -> Update testing and verification steps for Spark 3 kernels and private egress.
  - File: `README.md` -> Note Spark 3 image support and Workbench Spark kernels configuration.
  - Verification: Clean git diff and full test suite run.

---

## 3. Explicit Verification Steps
1. Run static analysis and validation:
   ```bash
   terraform fmt -check
   terraform validate
   ```
2. Run full test suite:
   ```bash
   python3 -m unittest discover tests
   ```
