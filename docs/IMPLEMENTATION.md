# Implementation Plan: Convert Dataproc to Standard Cluster (2 Worker Nodes, e2-standard-2)

## 1. Summary of Changes
Convert the Dataproc cluster from single-node (zero-worker) mode to a standard multi-node cluster architecture with 1 master node and 2 worker nodes, sized with `e2-standard-2` machine types.

- **`modules/dataproc/variables.tf`**:
  - Update `master_machine_type` default to `"e2-standard-2"`.
  - Add `worker_machine_type` variable with default `"e2-standard-2"`.
  - Add `worker_num_instances` variable with default `2`.
- **`modules/dataproc/main.tf`**:
  - Add `worker_config` block with `num_instances`, `machine_type`, and 50 GB standard persistent disk.
  - Remove zero-worker override property (`dataproc:dataproc.allow.zero.workers`).
- **`variables.tf`**:
  - Update `dataproc_master_machine_type` default to `"e2-standard-2"`.
  - Add `dataproc_worker_machine_type` (default `"e2-standard-2"`).
  - Add `dataproc_worker_num_instances` (default `2`).
- **`main.tf`**:
  - Pass `worker_machine_type` and `worker_num_instances` to `module.dataproc`.
- **`terraform.tfvars` & `terraform.tfvars.example`**:
  - Update `dataproc_master_machine_type = "e2-standard-2"`.
  - Add `dataproc_worker_machine_type = "e2-standard-2"` and `dataproc_worker_num_instances = 2`.
- **`tests/`**:
  - Update `test_dataproc_module.py`, `test_root_config.py`, and `test_root_orchestration.py` to assert standard cluster topology with worker configs.
- **Documentation**:
  - Update `README.md` and `docs/RUNBOOK.md` to reflect standard cluster topology.

---

## 2. Sequential Micro-Task Checklist

- [ ] **Task 1: Update Dataproc Module Tests & Configuration (TDD: RED -> GREEN)**
  - File: `tests/test_dataproc_module.py` -> Update assertions for `worker_config`, `worker_machine_type`, and `worker_num_instances`.
  - File: `modules/dataproc/variables.tf` -> Add worker variables and update master default to `"e2-standard-2"`.
  - File: `modules/dataproc/main.tf` -> Add `worker_config` and remove zero-worker override.
  - Verification: `python3 -m unittest tests/test_dataproc_module.py`

- [ ] **Task 2: Update Root Orchestrator & Variables (TDD: RED -> GREEN)**
  - File: `tests/test_root_config.py` & `tests/test_root_orchestration.py` -> Add assertions for worker variables and module wiring.
  - File: `variables.tf` -> Declare `dataproc_worker_machine_type` and `dataproc_worker_num_instances`, update master default to `"e2-standard-2"`.
  - File: `main.tf` -> Pass worker variables to `module.dataproc`.
  - File: `terraform.tfvars` & `terraform.tfvars.example` -> Set machine types to `"e2-standard-2"` and worker count to 2.
  - Verification: `python3 -m unittest tests/test_root_config.py tests/test_root_orchestration.py`

- [ ] **Task 3: Full Workspace Verification & Documentation Sync**
  - File: `README.md` & `docs/RUNBOOK.md` -> Update architecture descriptions from single-node to standard 2-worker cluster.
  - Verification: Run `python3 -m unittest discover tests`, `terraform validate`, and `terraform fmt -check`.
  - Merge feature branch into `main` and clean up ephemeral artifacts.

---

## 3. Explicit Verification Steps
```bash
python3 -m unittest discover tests
terraform validate
terraform fmt -check
```
