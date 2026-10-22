import os
import unittest

class TestRootConfig(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def test_versions_tf_exists(self):
        path = os.path.join(self.root_dir, "versions.tf")
        self.assertTrue(os.path.exists(path), "versions.tf must exist")
        with open(path) as f:
            content = f.read()
        self.assertIn('required_version', content)
        self.assertIn('hashicorp/google', content)
        self.assertIn('hashicorp/google-beta', content)

    def test_variables_tf_exists_and_contains_expected_vars(self):
        path = os.path.join(self.root_dir, "variables.tf")
        self.assertTrue(os.path.exists(path), "variables.tf must exist")
        with open(path) as f:
            content = f.read()
        for var in ["project_id", "region", "zone", "network_name", "subnet_cidr", "workbench_user_email", "dataproc_image_version", "dataproc_worker_machine_type", "dataproc_worker_num_instances"]:
            self.assertIn(f'variable "{var}"', content)

    def test_main_tf_enables_required_services(self):
        path = os.path.join(self.root_dir, "main.tf")
        self.assertTrue(os.path.exists(path), "main.tf must exist")
        with open(path) as f:
            content = f.read()
        for svc in [
            "compute.googleapis.com",
            "notebooks.googleapis.com",
            "dataproc.googleapis.com",
            "composer.googleapis.com",
            "storage.googleapis.com",
            "iam.googleapis.com"
        ]:
            self.assertIn(svc, content)

if __name__ == "__main__":
    unittest.main()
