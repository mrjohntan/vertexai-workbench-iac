import os
import unittest

class TestStorageModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "storage")

    def test_storage_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/storage")

    def test_storage_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/storage/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        self.assertIn("google_storage_bucket", content)
        self.assertIn("uniform_bucket_level_access = true", content)
        self.assertIn("roles/storage.objectUser", content)
        self.assertIn("roles/storage.objectAdmin", content)

    def test_storage_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/storage/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["data_bucket_name", "data_bucket_url", "dataproc_staging_bucket_name"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
