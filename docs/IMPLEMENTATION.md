# Implementation Plan: Grant Dataproc Editor & ServiceAccountUser to Cloud Composer Service Account

## 1. Problem Statement
Airflow tasks executed by the task runner in Cloud Composer 3 fail with:
```
google.api_core.exceptions.PermissionDenied: 403 Permission 'dataproc.clusters.use' denied on resource '//dataproc.googleapis.com/projects/vertexaiwb/regions/asia-southeast1/clusters/test-dataproc-kernel' (or it may not exist).
```
When `DataprocSubmitJobOperator` submits a PySpark job to Dataproc, the Cloud Composer Environment Service Account (`sa-composer`) requires:
1. `roles/dataproc.editor` on the project to manage Dataproc clusters and submit jobs.
2. `roles/iam.serviceAccountUser` on the Dataproc cluster service account (`sa-dataproc`) to run jobs under the cluster's service account identity.

## 2. Proposed Changes
- **`modules/iam/main.tf`**:
  - Add `roles/dataproc.editor` to `sa-composer` project role bindings.
  - Add `google_service_account_iam_member.composer_actas_dataproc` granting `roles/iam.serviceAccountUser` on `google_service_account.dataproc` to `serviceAccount:${google_service_account.composer.email}`.
- **`tests/test_iam_module.py`**:
  - Add assertions verifying `roles/dataproc.editor` is granted to the Composer SA and `composer_actas_dataproc` is declared.
- **`docs/RUNBOOK.md`**:
  - Document the Composer -> Dataproc IAM relationship in the troubleshooting section.

## 3. Sequential Micro-Task Checklist
- [ ] **Task 1: IAM Test Updates (RED)**
  - File: `tests/test_iam_module.py` -> Add assertions for Composer SA `roles/dataproc.editor` and `composer_actas_dataproc`.
  - Verification: `python3 -m unittest tests/test_iam_module.py` (fails as expected).

- [ ] **Task 2: IAM Module Implementation (GREEN)**
  - File: `modules/iam/main.tf` -> Bind `roles/dataproc.editor` to `google_service_account.composer` and grant `roles/iam.serviceAccountUser` on `google_service_account.dataproc`.
  - Verification: `python3 -m unittest tests/test_iam_module.py` (passes).

- [ ] **Task 3: Full Verification & Runbook Sync**
  - File: `docs/RUNBOOK.md` -> Update troubleshooting table with DataprocSubmitJobOperator remediation steps.
  - Run: `terraform validate` and `python3 -m unittest discover tests`.
  - Clean up ephemeral files and merge to `main`.
