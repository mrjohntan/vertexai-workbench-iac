# Operational Runbook: Vertex AI Workbench Testing Environment

This runbook guides engineers and maintainers through deploying, verifying, troubleshooting, and maintaining the private Vertex AI Workbench testing environment in `asia-southeast1`.

---

## 1. Deployment Procedures

### 1.1 First-Time Setup
1. Verify Google Cloud authentication and default application credentials:
   ```bash
   gcloud auth application-default print-access-token
   ```
2. Verify target project ID:
   ```bash
   gcloud config get-value project
   ```
3. Prepare configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Fill in project_id and workbench_user_email
   ```
4. Initialize and apply:
   ```bash
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```
   > **Note on Provisioning Time**: Cloud Composer 3 and Dataproc clusters take approximately 15–25 minutes to fully initialize.

---

## 2. Functional Verification Checklist

### 2.1 Verifying Private Workbench Access & Cloud NAT
1. Retrieve the Workbench Web Proxy URI from Terraform outputs:
   ```bash
   terraform output workbench_proxy_uri
   ```
2. In your browser (logged in with the email defined in `workbench_user_email`), open the URL or navigate in the Google Cloud Console to:
   **Vertex AI > Workbench > Instances** and click **Open JupyterLab**.
3. Open a **Terminal** inside JupyterLab:
   - Check internet access via Cloud NAT (should succeed without public IP):
     ```bash
     curl -I https://pypi.org
     pip install --user tabulate
     ```
   - Verify identity and service account attachment:
     ```bash
     gcloud auth list
     ```
     Confirm the active identity is `sa-workbench@<project-id>.iam.gserviceaccount.com`.

### 2.2 Verifying Cloud Storage Data Bucket Read/Write
1. From the Workbench JupyterLab terminal, test read and write access to the dedicated data bucket:
   ```bash
   DATA_BUCKET=$(gcloud compute instances describe $(hostname) --zone=asia-southeast1-a --format="value(metadata.items.data_bucket)" 2>/dev/null || terraform output -raw data_bucket_name)
   echo "Hello from Vertex AI Workbench" > test_payload.txt
   gsutil cp test_payload.txt gs://${DATA_BUCKET}/test_payload.txt
   gsutil cat gs://${DATA_BUCKET}/test_payload.txt
   ```
2. Verify object is written cleanly.

### 2.3 Verifying Dataproc Remote Kernel Execution
1. In Workbench JupyterLab, create a new Notebook (`.ipynb`).
2. Open the kernel switcher in the top right.
3. Select **Dataproc Cluster** > `test-dataproc-kernel` (PySpark).
4. Run the following cell:
   ```python
   from pyspark.sql import SparkSession
   spark = SparkSession.builder.appName("WorkbenchTest").getOrCreate()
   df = spark.range(1, 1001)
   print(f"Total count from remote Dataproc Spark: {df.count()}")
   ```
5. Confirm output returns `Total count from remote Dataproc Spark: 1000`.

### 2.4 Verifying Cloud Composer 3 Notebook Scheduling
1. With your test notebook open in Workbench JupyterLab, click the **Schedule** or **Execute Notebook** button in the top toolbar.
2. In the execution dialogue:
   - Select **Cloud Composer**.
   - Pick the provisioned Composer environment (`test-composer-env`).
   - Set schedule to **Once** or **Hourly**.
   - Click **Submit**.
3. Retrieve the Airflow Web UI from Terraform outputs:
   ```bash
   terraform output composer_airflow_uri
   ```
4. Open the Airflow Web UI and verify that the newly generated DAG appears in the active DAG list and triggers execution.

---

## 3. Troubleshooting & Debugging

| Symptom | Probable Cause | Remediation Steps |
|---|---|---|
| Cannot open JupyterLab from Console | User not set in `instance_owners` or missing `roles/notebooks.admin` / `viewer` | Ensure `workbench_user_email` matches user Google Cloud identity. Check IAM bindings on project. |
| `pip install` fails with network timeout inside Workbench | Cloud NAT not routing or route missing | Verify `google_compute_router_nat.nat` is healthy. Verify route `0.0.0.0/0` -> `default-internet-gateway` exists in VPC. |
| Dataproc cluster kernel does not appear in Workbench | Component Gateway disabled or internal firewall blocking ports | Confirm `endpoint_config.enable_http_port_access = true`. Check firewall rule `allow-internal` covers `10.10.0.0/24`. |
| Dataproc creation fails with missing permissions on temp_bucket | Custom VM service account lacks `storage.buckets.get` or dedicated `temp_bucket` omitted | Ensure `temp_bucket = var.temp_bucket_name` is configured in Dataproc cluster and `roles/storage.admin` is granted on both staging and temp buckets. |
| Composer DAG upload returns `Permission Denied` from Workbench | Missing `roles/storage.objectUser` on Composer DAGs bucket | Verify `google_storage_bucket_iam_member.workbench_dag_access` exists in state. |

---

## 4. Maintenance & Cost Optimization

- **Pausing Idle Compute**:
  When testing is paused, stop the Workbench instance to save compute costs:
  ```bash
  gcloud workbench instances stop test-workbench-instance --location=asia-southeast1-a
  ```
- **Tearing Down Data Services**:
  To delete Dataproc or Composer without deleting the VPC:
  ```bash
  terraform destroy -target=module.dataproc -target=module.composer
  ```
- **Complete Destruction**:
  ```bash
  terraform destroy
  ```
