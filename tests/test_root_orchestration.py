import os
import unittest

class TestRootOrchestration(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def test_main_tf_module_calls(self):
        path = os.path.join(self.root_dir, "main.tf")
        with open(path) as f:
            content = f.read()

        for mod in ["networking", "iam", "storage", "dataproc", "composer", "workbench"]:
            self.assertIn(f'module "{mod}"', content)
        self.assertIn("temp_bucket_name    = module.storage.dataproc_temp_bucket_name", content)
        self.assertIn("image_version       = var.dataproc_image_version", content)
        self.assertIn("dataproc_cluster_name = module.dataproc.cluster_name", content)
        self.assertIn("dataproc_region       = var.region", content)

    def test_outputs_tf_declarations(self):
        path = os.path.join(self.root_dir, "outputs.tf")
        self.assertTrue(os.path.exists(path), "outputs.tf must exist in root")
        with open(path) as f:
            content = f.read()

        for out in ["workbench_proxy_uri", "dataproc_cluster_name", "composer_airflow_uri", "data_bucket_url", "workbench_sa_email"]:
            self.assertIn(f'output "{out}"', content)

    def test_tfvars_example_exists(self):
        path = os.path.join(self.root_dir, "terraform.tfvars.example")
        self.assertTrue(os.path.exists(path), "terraform.tfvars.example must exist")
        with open(path) as f:
            content = f.read()

        for var in ["project_id", "workbench_user_email", "region", "zone"]:
            self.assertIn(var, content)

if __name__ == "__main__":
    unittest.main()
