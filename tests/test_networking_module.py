import os
import unittest

class TestNetworkingModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "networking")

    def test_networking_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/networking")

    def test_networking_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/networking/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        self.assertIn("google_compute_network", content)
        self.assertIn("auto_create_subnetworks = false", content)
        self.assertIn("google_compute_subnetwork", content)
        self.assertIn("private_ip_google_access = true", content)
        self.assertIn("google_compute_router", content)
        self.assertIn("google_compute_router_nat", content)
        self.assertIn("google_compute_firewall", content)
        self.assertIn("35.235.240.0/20", content) # IAP CIDR

    def test_networking_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/networking/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["network_id", "network_name", "subnet_id", "subnet_name"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
