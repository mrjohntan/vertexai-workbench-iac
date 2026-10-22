import os
import unittest

class TestWorkbenchModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "workbench")

    def test_workbench_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/workbench")

    def test_workbench_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/workbench/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        self.assertIn("google_workbench_instance", content)
        self.assertIn("gce_setup", content)
        self.assertIn("network_interfaces", content)
        self.assertIn("service_accounts", content)
        self.assertIn("vm_image", content)
        self.assertIn("instance_owners", content)
        self.assertIn("idle-timeout-seconds", content)
        self.assertIn('"disable-mixer"', content)
        self.assertIn('"dataproc-cluster-name"', content)
        self.assertIn('"dataproc-region"', content)
        self.assertIn("disable_public_ip = var.disable_public_ip", content)

    def test_workbench_variables(self):
        path = os.path.join(self.mod_dir, "variables.tf")
        with open(path) as f:
            content = f.read()
        self.assertIn('variable "disable_public_ip"', content)
        self.assertIn('default     = true', content)
        self.assertIn('variable "dataproc_cluster_name"', content)
        self.assertIn('variable "dataproc_region"', content)

    def test_workbench_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/workbench/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["instance_id", "instance_name", "proxy_uri"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
