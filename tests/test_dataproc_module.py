import os
import unittest

class TestDataprocModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "dataproc")

    def test_dataproc_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/dataproc")

    def test_dataproc_single_node_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/dataproc/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        self.assertIn("google_dataproc_cluster", content)
        self.assertIn("master_config", content)
        # Verify worker_config is NOT defined (API rule for zero workers)
        self.assertNotIn("worker_config", content)
        self.assertIn("dataproc:dataproc.allow.zero.workers", content)
        self.assertIn("enable_http_port_access = true", content)
        self.assertIn('"JUPYTER"', content)
        self.assertIn("staging_bucket = var.staging_bucket_name", content)
        self.assertIn("temp_bucket    = var.temp_bucket_name", content)
        self.assertIn("internal_ip_only = true", content)
        self.assertIn("lifecycle_config", content)
        self.assertIn("idle_stop_ttl", content)

    def test_dataproc_variables(self):
        path = os.path.join(self.mod_dir, "variables.tf")
        with open(path) as f:
            content = f.read()
        self.assertIn('variable "temp_bucket_name"', content)
        self.assertIn('variable "staging_bucket_name"', content)

    def test_dataproc_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/dataproc/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["cluster_name", "cluster_id"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
